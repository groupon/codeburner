#``
#The MIT License (MIT)
#
#Copyright (c) 2016, Groupon, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
# require 'sidekiq'
# require 'sidekiq/testing/inline'

class Api::GithubController < ApplicationController
  respond_to :json
  before_filter :authz, only: [ :search, :branches ]

  def search
    permitted_types = ['repos', 'users']

    return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:q) and permitted_types.include?(params[:type])

    results = CodeburnerUtil.user_github(@current_user).send("search_#{params[:type]}", params[:q])
    render(:json => results.to_hash)
  end

  def branches
    return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:repo)

    results = CodeburnerUtil.user_github(@current_user).branches(params[:repo])
    render(:json => results.map{|r| r.to_hash})
  end

  def webhook
    event = request.headers['X-GitHub-Event']
    pull_request = nil

    if event == 'push'
      repo = Service.find_by_short_name(params[:repository][:full_name])
      branch = params[:ref].split('/').last
      revision = params[:after]
    elsif event == 'pull_request'
      parent_repo   = Service.find_by(:short_name => params[:pull_request][:base][:repo][:full_name])
      repo          = Service.create_with(:webhook_user => parent_repo.webhook_user, :repo_url => params[:pull_request][:head][:repo][:html_url]).find_or_create_by(:short_name => params[:pull_request][:head][:repo][:full_name])
      branch        = params[:pull_request][:head][:ref]
      revision      = params[:pull_request][:head][:sha]
      pull_request  = params[:pull_request][:base][:repo][:full_name]

      if params[:pull_request][:state] == 'closed'
        if params[:pull_request][:merged]
          old_burn = Burn.service_id(repo.id).branch(branch).revision(revision).pull_request(pull_request).status('done').order('created_at').last

          unless old_burn.nil?
            if branch != params[:pull_request][:base][:ref] or parent_repo != repo
              parent_repo.findings.update_all(:current => false)
              new_burn = Burn.create(:service => parent_repo, :branch => params[:pull_request][:base][:ref], :revision => params[:pull_request][:merge_commit_sha])

              findings = old_burn.findings.dup
              findings.update_all(:service_id => parent_repo.id, :burn_id => new_burn.id, :current => true)

              new_burn.update(:status => 'done')
            end
          end

          return render(:json => {result: 'merged'})
        else
          return render(:json => {result: 'closed'})
        end
      end
    else
      return render(:json => {error: "invalid event"})
    end

    return render(:json => {error: "repository not found"}, :status => 400) unless repo

    github = CodeburnerUtil.user_github(repo.webhook_user)

    duplicate_burn = Burn.service_short_name(repo.short_name).branch(branch).revision(revision).order("created_at").last
    if duplicate_burn
      unless duplicate_burn.status == 'failed'
        if duplicate_burn.findings.status(0).count == 0
          github.create_status parent_repo.short_name, revision, 'success', :context => 'Codeburner', :description => 'Static security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?service_id=#{repo.id}"
        else
          github.create_status parent_repo.short_name, revision, 'failure', :context => 'Codeburner', :description => 'Static security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?service_id=#{repo.id}"
        end
        return render(:json => {error: "Already burning #{repo.short_name} - #{revision}"})
      end
    end

    repo_url = github.repo(repo.short_name).html_url

    burn = Burn.create({:user => repo.webhook_user, :service => repo, :branch => branch, :revision => revision, :repo_url => repo_url, :status_reason => "created via github webhook on #{Time.now}", :report_status => true, :pull_request => pull_request})

    BurnWorker.perform_async burn.id

    render(:json => {burn_id: burn.id, repository: repo, branch: branch, revision: burn.revision, status: burn.status})
  end

end
