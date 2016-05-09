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
class Api::FindingController < ApplicationController
  respond_to :json

  before_filter :authz_no_fail, only: [ :publish ]
  # START ServiceDiscovery
  # resource: findings.index
  # description: Search findings
  # method: GET
  # path: /finding
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       required: false
  #       location: query
  #       description: A comma-separated list of finding IDs
  #     service_id:
  #       type: integer
  #       required: false
  #       location: query
  #       description: A comma-separated list of service IDs
  #     burn_id:
  #       type: integer
  #       required: false
  #       location: query
  #       description: A comma-separated list of burn IDs
  #     service_name:
  #       type: string
  #       required: false
  #       location: query
  #       description: A case-insensitve search for a specific service name (short or long form)
  #     severity:
  #       type: integer
  #       required: false
  #       location: query
  #       description: The current finding status code
  #     description:
  #       type: string
  #       required: false
  #       location: query
  #       description: The finding description
  #     fingerprint:
  #       type: string
  #       required: false
  #       location: query
  #       description: the SHA256 fingerprint
  #     status:
  #       type: integer
  #       required: false
  #       location: query
  #       description: the finding status code
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
  #   name: findings
  #   description: Hash containing a count of total results and an Array of results per pagination options
  #   type: object
  #   properties:
  #     count:
  #       type: integer
  #       description: number of total results
  #     results:
  #       type: array
  #       description: list of findings
  #       items:
  #         $ref: findings.show.response
  # END ServiceDiscovery
  def index
    safe_sorts = ['id', 'service_id', 'service_name', 'severity', 'fingerprint', 'status', 'description']
    sort_by = 'findings.id'
    order = nil

    if params[:sort_by] == 'service_name'
      sort_by = "services.pretty_name"
    else
      sort_by = "#{params[:sort_by]}" if safe_sorts.include? params[:sort_by]
    end

    unless params[:order].nil?
      order = params[:order].upcase if ['ASC','DESC'].include? params[:order].upcase
    end

    if params.has_key?(:only_current) and ["false", "no", "n"].include? params[:only_current].downcase
      only_current = false
    else
      only_current = true
    end

    results = Finding.only_current(only_current) \
      .id(params[:id]) \
      .service_id(params[:service_id]) \
      .branch(params[:branch]) \
      .burn_id(params[:burn_id]) \
      .service_name(params[:service_name]) \
      .severity(params[:severity]) \
      .description(params[:description]) \
      .fingerprint(params[:fingerprint]) \
      .status(params[:status]) \
      .order("#{sort_by} #{order}") \
      .page(params[:page]) \
      .per(params[:per_page])

    if params.has_key?(:filtered_by)
      results = results.filtered_by(params[:filtered_by])
    end

    render(:json => { "count": results.total_count, "results": results })
  end

  # START ServiceDiscovery
  # resource: findings.show
  # description: Show a finding
  # method: GET
  # path: /finding/:id
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: Finding ID
  #       location: url
  #       required: true
  #
  # response:
  #   name: finding
  #   description: a finding object
  #   type: object
  #   properties:
  #     id:
  #       type: integer
  #       description: finding ID
  #     burn_id:
  #       type: integer
  #       description: ID of the burn associated with this finding
  #     service_id:
  #       type: integer
  #       descritpion: the service ID
  #     severity:
  #       type: integer
  #       description: severity code (0 - 3)
  #     fingerprint:
  #       type: string
  #       description: the SHA256 fingerprint
  #     scanner:
  #       type: string
  #       description: scanning software used
  #     description:
  #       type: string
  #       description: finding description
  #     detail:
  #       type: string
  #       description: finding detail
  #     file:
  #       type: string
  #       description: file name
  #     line:
  #       type: string
  #       description: line number
  #     code:
  #       type: text
  #       description: code snippet
  # END ServiceDiscovery
  def show
    render(:json => Finding.find(params[:id]).as_json)
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no finding with that id found}"}, :status => 404)
  end

  # START ServiceDiscovery
  # resource: findings.update
  # description: update findings
  # method: PUT
  # path: /finding/:id
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       required: false
  #       location: url
  #       description: A finding ID
  #     status:
  #       type: integer
  #       required: false
  #       location: query
  #       description: the finding status code
  #
  # response:
  #   $ref: findings.show.response
  # END ServiceDiscovery
  def update
    return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:id)

    updateable_attributes = [ :status ]
    fields_to_update = updateable_attributes.select{ |a| !params[a].nil? }
    finding = Finding.find(params[:id])

    return render(:json => {error: "availble attributes: #{updateable_attributes.join(', ')}"}, :status => 400) unless !fields_to_update.nil?

    fields_to_update.each do |field|
      finding.update_attribute(field, params[field])
    end

    Rails.cache.write('stats', CodeburnerUtil.get_stats)
    render(:json => finding.as_json)
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no finding with that id found}"}, :status => 404)
  end

  # START ServiceDiscovery
  # resource: findings.publish
  # description: publish finding to JIRA
  # method: PUT
  # path: /finding/:id/publish
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       required: true
  #       location: url
  #       description: A finding ID
  #     project:
  #       type: string
  #       required: true
  #       location: query
  #       description: the JIRA project ID to publish the finding in
  #
  # response:
  #   name: results
  #   description: A count of results and list of JIRA tickets generated
  #   type: object
  #   properties:
  #     count:
  #       type: integer
  #       description: total results
  #     results:
  #       type: array
  #       description: list of JIRA tickets generated
  #       items:
  #         type: string
  #         description: JIRA ticket number
  #
  # END ServiceDiscovery
  def publish
    return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:id) and params.has_key?(:method)

    if params[:method].downcase == "jira"
      return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:project)
    end

    finding = Finding.find(params[:id])

    ticket, link = nil, nil

    case params[:method].downcase
    when "jira"
      result = publish_to_jira(finding.id, params[:project])
      ticket = result['key'] if result.has_key?('key')
      link = "#{Setting.jira.link_host}/browse/#{ticket}"
    when "github"
      return render(:json => {:error => "GitHub Authentication Required"}, :status => 403) if @current_user == nil

      repo = CodeburnerUtil.strip_github_path(finding.burn.repo_url)
      result = publish_to_github(@current_user, finding.id, repo)

      ticket = "#{repo} - Issue ##{result.number}"
      link = result.html_url
    else
      return render(:json => {error: "unsupported publishing method"}, :status => 400)
    end

    if ticket.nil? or link.nil?
      return render(:json => {error: 'publishing failed'}, :status => 500)
    end

    render(:json => {:ticket => ticket, :link => link})
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no finding with that id found}"}, :status => 404)
  end

  def publish_to_github (user, finding_id, repo)
    user_github = Octokit::Client.new(:access_token => @current_user.access_token)
    @finding = Finding.find(finding_id)
    @severity = CodeburnerUtil.severity_to_text(@finding.severity)
    @details = @finding.detail.split(',').join("\n")
    result = user_github.create_issue(repo, @finding.description, render_to_string("github"))

    if result
      @finding.update(:status => 2)
      return result
    else
      return nil
    end
  end

  def publish_to_jira (finding_id, project)
    @finding = Finding.find(finding_id)
    @severity = CodeburnerUtil.severity_to_text(@finding.severity)
    @details = @finding.detail.split(',').join("\n")
    description = render_to_string "jira"

    jira_options = {
      :site => Setting.jira.host,
      :username => Setting.jira.username,
      :password => Setting.jira.password,
      :context_path => Setting.jira.context_path,
      :auth_type => :basic,
      :use_ssl => Setting.jira.use_ssl
    }

    jira = JIRA::Client.new(jira_options)

    issue = jira.Issue.build
    result = issue.save({
      "fields" => {
        "project" => {
          "key" => project
        },
        "issuetype" => {
          "name" => "Task"
        },
        "summary" => "#{@finding.service.pretty_name} - #{@finding.description}",
        "description" => description,
        "labels" => [ "security-issue", @finding.service.short_name.downcase.gsub(' ','-').gsub(/\p{^Alnum}-/, '') ]
      }
    })

    if result
      @finding.update(:status => 2)
      return issue.attrs
    else
      return nil
    end
  end

end
