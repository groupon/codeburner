class Api::ServiceController < ApplicationController
  respond_to :json

  # START ServiceDiscovery
  # resource: services.index
  # description: Show all services with associated burns
  # method: GET
  # path: /service
  #
  # response:
  #   name: services
  #   description: a hash containing a result count and list of services
  #   type: object
  #   properties:
  #     count:
  #       type: integer
  #       description: number of results
  #     results:
  #       type: array
  #       descritpion: the list of services
  #       items:
  #         $ref: services.show.response
  # END ServiceDiscovery
  def index
    services = Rails.cache.fetch('services') { CodeburnerUtil.get_services }

    render(:json => { "count": services.length, "results": services })
  end

  # START ServiceDiscovery
  # resource: services.show
  # description: show a service
  # method: GET
  # path: /service/:id
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: service ID
  #       location: url
  #       required: true
  #
  # response:
  #   name: service
  #   description: a service object
  #   type: object
  #   properties:
  #     id:
  #       type: integer
  #       description: service ID
  #     short_name:
  #       type: string
  #       description: the unique identifying name of the service
  #     pretty_name:
  #       type: string
  #       description: the long-form display name of the service
  #     service_portal:
  #       type: boolean
  #       description: service is from service-portal?
  #
  # END ServiceDiscovery
  def show
    render(:json => Service.find(params[:id]))
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no service with that id found}"}, :status => 404)
  end

  # START ServiceDiscovery
  # resource: services.stats
  # description: show statistics on a service
  # method: GET
  # path: /service/:ids/stats
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: service ID
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
  #       description: number of burns run against the service
  #     total_findings:
  #       type: integer
  #       description: the total number of findings for the service
  #     open_findings:
  #       type: integer
  #       description: the number of findings that aren't hidden/published/filtered
  #     hidden_findings:
  #       type: integer
  #       description: the number of hidden findings for a service
  #     published_findings:
  #       type: integer
  #       description: the number of published findings for a service
  #     filtered_findings:
  #       type: integer
  #       description: the number of filtered findings for a service
  #     last_burn:
  #       type: object
  #       description: the last burn performed against a service
  #       properties:
  #         $ref: burns.show.response
  #
  # END ServiceDiscovery
  def stats
    service = Service.find(params[:id])

    respond_to do |format|
      format.html { render(:json => CodeburnerUtil.get_service_stats(service.id)) }
      format.json { render(:json => CodeburnerUtil.get_service_stats(service.id)) }
    end
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
    service = Service.find(params[:id])

    render(:json => CodeburnerUtil.get_history(params[:start_date], params[:end_date], params[:resolution], nil, service.id))
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "Service or findings not found}"}, :status => 404)
  end

  def burns
    render(:json => CodeburnerUtil.get_burn_history(params[:start_date], params[:end_date], params[:id]))
  end
end
