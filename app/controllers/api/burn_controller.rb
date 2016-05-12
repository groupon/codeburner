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

# Uncomment the following lines to test the burn process inline (and debug w/ pry etc.
#)
require 'sidekiq'
require 'sidekiq/testing/inline'

class Api::BurnController < ApplicationController
  protect_from_forgery
  respond_to :json, :html
  before_filter :authz, only: [ :destroy, :reignite ]

  # START ServiceDiscovery
  # resource: burns.index
  # description: Search burns
  # method: GET
  # path: /burn
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       required: false
  #       location: query
  #       description: A comma-separated list of burn IDs
  #     service_id:
  #       type: integer
  #       required: false
  #       location: query
  #       description: A comma-separated list of service IDs
  #     service_name:
  #       type: string
  #       required: false
  #       location: query
  #       description: A case-insensitve search for a specific service name (short or long form)
  #     revision:
  #       type: string
  #       required: false
  #       location: query
  #       description: The commit SHA or tag of a specific service revision
  #     status:
  #       type: string
  #       required: false
  #       location: query
  #       description: One of created, burning, done, failed representing the current burn status
  #     sort_by:
  #       type: string
  #       required: false
  #       location: query
  #       description: The field to sort by, supported fields are id, service_id, service_name, revision, code_lang, repo_url, status
  #     per_page:
  #       type: integer
  #       required: false
  #       location: query
  #       description: number of results per page, only used in conjunction with the page param
  #     page:
  #       type: integer
  #       required: false
  #       location: query
  #       description: current page of results to display, used in conjunction with the per_page param
  #
  # response:
  #   name: burns
  #   description: Hash containing a count of total results and an Array of results per pagination options
  #   type: object
  #   properties:
  #     count:
  #       type: integer
  #       description: number of total results
  #     results:
  #       type: array
  #       description: list of burns
  #       items:
  #         $ref: burns.show.response
  # END ServiceDiscovery
  def index
    if params[:page] == '1' and params[:per_page] == '10' and params[:sort_by] == 'count' and params[:order] == 'desc'
      burn_list = Rails.cache.fetch('burn_list') { CodeburnerUtil.get_burn_list }
      return render(:json => {count: Rails.cache.fetch('stats'){CodeburnerUtil.get_stats}[:burns], results: burn_list })
    end

    safe_sorts = ['id', 'service_id', 'service_name', 'revision', 'code_lang', 'repo_url', 'status']
    sort_by = 'burns.id'
    order = nil

    if params[:sort_by] == 'service_name'
      sort_by = "services.pretty_name"
    else
      sort_by = "#{params[:sort_by]}" if safe_sorts.include? params[:sort_by]
    end

    unless params[:order].nil?
      order = params[:order].upcase if ['ASC','DESC'].include? params[:order].upcase
    end

    burns = Burn.id(params[:id]) \
      .service_id(params[:service_id]) \
      .service_name(params[:service_name]) \
      .revision(params[:revision]) \
      .status(params[:status]) \
      .order("#{sort_by} #{order}") \
      .page(params[:page]) \
      .per(params[:per_page]) \

    render(:json => {count: burns.total_count, results: burns})
  end

  # START ServiceDiscovery
  # resource: burns.show
  # description: show a burn
  # method: GET
  # path: /burn/:id
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: Burn ID
  #       location: url
  #       required: true
  #
  # response:
  #   name: burn
  #   description: a burn object
  #   type: object
  #   properties:
  #     id:
  #       type: integer
  #       description: burn ID
  #     revision:
  #       type: string
  #       description: commit SHA or git tag for a specific service revision
  #     status:
  #       type: string
  #       description: the current burn status
  #     repo_url:
  #       type: string
  #       description: the github repository URL
  #     code_lang:
  #       type: string
  #       description: a comma-separated list of code languages detected
  #     num_files:
  #       type: integer
  #       description: the number of files scanned
  #     num_lines:
  #       type: integer
  #       description: the number of lines scanned
  #     service_id:
  #       type: integer
  #       description: the service ID
  #     service_portal:
  #       type: boolean
  #       description: is this a service known to service portal?
  #     status_reason:
  #       type: string
  #       description: the reason for the current status
  # END ServiceDiscovery
  def show
    render(:json => Burn.find(params[:id]).as_json)
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no burn with that id found}"}, :status => 404)
  end

  # START ServiceDiscovery
  # resource: burns.create
  # description: Initiates a scan of a specific revision of code stored in github
  # method: POST
  # path: /burn
  #
  # request:
  #   parameters:
  #     service_name:
  #       type: string
  #       description: a reference to the service_id in service-portal
  #       location: body
  #       required: true
  #     service_portal:
  #       type: boolean
  #       description: is this a service portal service?
  #       location: body
  #       required: false
  #     repo_url:
  #       type: string
  #       description: The github repository URL, required for service_portal = false
  #       location: body
  #       required: false
  #     revision:
  #       type: string
  #       description: the git tag/sha of the release to be scanned
  #       location: body
  #       required: true
  # response:
  #   name: result
  #   description: Result of the call
  #   type: object
  #   properties:
  #     service_name:
  #       type: string
  #       description: The identifying service name
  #     revision:
  #       type: string
  #       description: the revision
  #     status:
  #       type: string
  #       description: created
  # END ServiceDiscovery
  def create
    return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:service_name)

    repo_url = "#{Setting.github['link_host']}/#{params[:service_name]}"
    params[:branch] ||= 'refs/heads/master'
    revision = CodeburnerUtil.get_head_commit(repo_url, params[:branch])

    duplicate_burn = Burn.service_short_name(params[:service_name]).revision(revision)
    if duplicate_burn.count > 0
      unless duplicate_burn.status('failed').count > 0 and duplicate_burn.status('done').count == 0
        return render(:json => {error: "Already burning #{params[:service_name]} release #{revision}"}, :status => 409)
      end
    end

    service = Service.find_by_short_name(params[:service_name])
    service = Service.create({:short_name => params[:service_name], :pretty_name => params[:service_name]}) if service.nil?

    burn = Burn.create({:service => service, :branch => params[:branch], :revision => revision, :repo_url => repo_url, :status_reason => "created on #{Time.now}"})

    if params.has_key?(:notify)
      Notification.create({:burn => burn.id.to_s, :method => 'email', :destination => params[:notify]})
    end

    render(:json => {burn_id: burn.id, service_id: service.id, service_name: params[:service_name], revision: burn.revision, status: burn.status})

    BurnWorker.perform_async(burn.id)
  end

  def reignite
    burn = Burn.find(params[:id])
    github = CodeburnerUtil.user_github(@current_user)
    has_push_perms = github.repo(burn.service.short_name).permissions.push

    return render(:json => {error: "User #{@current_user.name} does not have push access to #{burn.service.short_name}"}) unless has_push_perms or @current_user.admin?

    new_burn = burn.dup
    new_burn.status = 'created'
    new_burn.save

    github.create_status new_burn.service.short_name, new_burn.revision, 'pending', :context => 'Codeburner', :description => 'Static security analysis', :target_url => "#{Setting.email['link_host']}/\#burns" if new_burn.report_status

    render(:json => {burn_id: new_burn.id, revision: new_burn.revision, status: new_burn.status})

    BurnWorker.perform_async(new_burn.id)
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no burn with that id found}"}, :status => 404)
  end

end
