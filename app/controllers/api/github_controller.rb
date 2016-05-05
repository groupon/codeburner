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
  before_filter :authz, only: [ :search ]

  def search
    permitted_types = ['repos', 'users']

    return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:q) and permitted_types.include?(params[:type])

    results = CodeburnerUtil.user_github(@current_user).send("search_#{params[:type]}", params[:q])
    render(:json => results.to_hash)
  end

  def webhook
    event = request.headers['X-GitHub-Event']

    if event == 'push'
      return render(:json => {error: "only scanning pushes to master branch"}) unless params[:ref] == 'refs/heads/master'

      repo = Service.find_by_short_name(params[:repository][:full_name])
      revision = params[:after]
    elsif event == 'pull_request'
      repo = Service.find_by_short_name(params[:pull_request][:head][:repo][:full_name])
      revision = params[:pull_request][:head][:sha]

      if params[:pull_request][:state] == 'closed'
        Burn.where(:revision => revision).each do |burn|
          Finding.burn_id(burn.id).destroy_all
          Burn.destroy(burn.id)
        end

        Finding.burn_id(Burn.service_id(repo.id).status('done').last.id).update_all(:current => true)

        return render(:json => {result: 'closed'})
      end
      # return render(:json => {error: "only scanning on open state"}) unless params[:pull_request][:state] == 'open'
    else
      return render(:json => {error: "invalid event"})
    end

    return render(:json => {error: "repository not found"}, :status => 400) unless repo

    duplicate_burn = Burn.service_short_name(repo.short_name).revision(revision)
    if duplicate_burn.count > 0
      unless duplicate_burn.status('failed').count > 0 and duplicate_burn.status('done').count == 0
        return render(:json => {error: "Already burning #{repo.short_name} - #{revision}"})
      end
    end

    github = CodeburnerUtil.user_github(repo.webhook_user)

    repo_url = github.repo(repo.short_name).html_url

    burn = Burn.create({:user => repo.webhook_user, :service => repo, :revision => revision, :repo_url => repo_url, :status_reason => "created via github webhook on #{Time.now}", :report_status => true})

    BurnWorker.perform_async burn.id

    render(:json => {burn_id: burn.id, repository: repo, revision: burn.revision, status: burn.status})
  end

end
