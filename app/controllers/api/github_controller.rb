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

    if params[:type] == 'repos'
      query = "#{params[:q]} fork:true"
    else
      query = params[:q]
    end

    results = CodeburnerUtil.user_github(@current_user).send("search_#{params[:type]}", query)
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
      repo = Repo.find_by_name(params[:repository][:full_name])
      branch = Branch.find_or_create_by(:repo_id => repo.id, :name => params[:ref].split('/').last)
      revision = params[:after]
    elsif event == 'pull_request' and ['opened', 'closed', 'reopened', 'synchronize'].include? params[:github][:action]
      repo          = Repo.find_by(:name => params[:pull_request][:base][:repo][:full_name])
      branch        = Branch.find_or_create_by(:repo_id => repo.id, :name => params[:pull_request][:base][:ref])
      revision      = params[:pull_request][:head][:sha]
      pull_request  = params[:number]

      if params[:pull_request][:state] == 'closed'
        if params[:pull_request][:merged]
          old_burn = Burn.repo_id(repo.id).branch_name(branch.name).revision(revision).pull_request(pull_request).status('done').order('created_at').last

          unless old_burn.nil?
            repo.findings.update_all(:current => false)

            old_burn.findings.update_all(:current => true)
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

    duplicate_burn = Burn.repo_name(repo.name).branch_name(branch.name).revision(revision).order("created_at").last
    if duplicate_burn
      unless duplicate_burn.status == 'failed'
        if duplicate_burn.findings.status(0).count == 0
          github.create_status repo.name, revision, 'success', :context => 'Codeburner', :description => 'codeburner security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?repo_id=#{repo.id}&branch=#{duplicate_burn.branch.name}&burn_id=#{duplicate_burn.id}&only_current=false"
        else
          github.create_status repo.name, revision, 'failure', :context => 'Codeburner', :description => 'codeburner security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?repo_id=#{repo.id}&branch=#{duplicate_burn.branch.name}&burn_id=#{duplicate_burn.id}&only_current=false"
        end
        return render(:json => {error: "Already burning #{repo.name} - #{revision}"})
      end
    end

    repo_url = github.repo(repo.name).html_url

    burn = Burn.create({:user => repo.webhook_user, :repo => repo, :branch => branch, :revision => revision, :repo_url => repo_url, :status_reason => "created via github webhook on #{Time.now}", :report_status => true, :pull_request => pull_request})

    BurnWorker.perform_async burn.id

    render(:json => {burn_id: burn.id, repository: repo, branch: branch.name, revision: burn.revision, status: burn.status})
  end

end
