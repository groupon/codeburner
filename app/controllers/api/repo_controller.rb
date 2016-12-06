#
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
class Api::RepoController < ApplicationController
  respond_to :json

  # START ServiceDiscovery
  # resource: repos.index
  # description: Show all repos with associated burns
  # method: GET
  # path: /repo
  #
  # response:
  #   name: repos
  #   description: a hash containing a result count and list of repos
  #   type: object
  #   properties:
  #     count:
  #       type: integer
  #       description: number of results
  #     results:
  #       type: array
  #       descritpion: the list of repos
  #       items:
  #         $ref: repos.show.response
  # END ServiceDiscovery
  def index
    repos = CodeburnerUtil.get_repos

    render(:json => { "count": repos.length, "results": repos })
  end

  # START ServiceDiscovery
  # resource: repos.show
  # description: show a repo
  # method: GET
  # path: /repo/:id
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: repo ID
  #       location: url
  #       required: true
  #
  # response:
  #   name: repo
  #   description: a repo object
  #   type: object
  #   properties:
  #     id:
  #       type: integer
  #       description: repo ID
  #     name:
  #       type: string
  #       description: the unique identifying name of the repo
  #     full_name:
  #       type: string
  #       description: the long-form display name of the repo
  #     repo_portal:
  #       type: boolean
  #       description: repo is from repo-portal?
  #
  # END ServiceDiscovery
  def show
    render(:json => Repo.find(params[:id]).to_json)
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no repo with that id found}"}, :status => 404)
  end

  # START ServiceDiscovery
  # resource: repos.stats
  # description: show statistics on a repo
  # method: GET
  # path: /repo/:ids/stats
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: repo ID
  #       location: url
  #       required: true
  #
  # response:
  #   name: stats
  #   description: stats
  #   type: object
  #   properties:
  #     burn_count:
  #       type: integer
  #       description: number of burns run against the repo
  #     total_findings:
  #       type: integer
  #       description: the total number of findings for the repo
  #     open_findings:
  #       type: integer
  #       description: the number of findings that aren't hidden/published/filtered
  #     hidden_findings:
  #       type: integer
  #       description: the number of hidden findings for a repo
  #     published_findings:
  #       type: integer
  #       description: the number of published findings for a repo
  #     filtered_findings:
  #       type: integer
  #       description: the number of filtered findings for a repo
  #     last_burn:
  #       type: object
  #       description: the last burn performed against a repo
  #       properties:
  #         $ref: burns.show.response
  #
  # END ServiceDiscovery
  def stats
    repo = Repo.find(params[:id])

    render(:json => CodeburnerUtil.get_repo_stats(repo.id))
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "Service or findings not found}"}, :status => 404)
  end

  def history_range
    render(:json => CodeburnerUtil.get_history_range(params[:id]))
  end

  def history_resolution
    render(:json => CodeburnerUtil.history_resolution(Time.parse(params[:start_date]), Time.parse(params[:end_date])).to_i)
  end

  def history
    repo = Repo.find(params[:id])

    render(:json => CodeburnerUtil.get_history(params[:start_date], params[:end_date], params[:resolution], nil, repo.id))
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "Service or findings not found}"}, :status => 404)
  end

  def branches
    render(:json => Branch.where(:repo_id => params[:id]))
  end

  def burns
    repo = Repo.find(params[:id])
    render(:json => CodeburnerUtil.get_burn_history(params[:start_date], params[:end_date], repo.id))
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "Service or findings not found}"}, :status => 404)
  end
end
