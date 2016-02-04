class Api::FilterController < ApplicationController
  respond_to :json

  # START ServiceDiscovery
  # resource: filters.index
  # description: Show all filters
  # method: GET
  # path: /filter
  #
  # response:
  #   name: filters
  #   description: a hash containing a result count and list of filters
  #   type: object
  #   properties:
  #     count:
  #       type: integer
  #       description: number of results
  #     results:
  #       type: array
  #       descritpion: the list of filters
  #       items:
  #         $ref: filters.show.response
  # END ServiceDiscovery
  def index
    safe_sorts = ['id', 'service_id' ]
    sort_by = 'filters.id'
    order = nil

    sort_by = "#{params[:sort_by]}" if safe_sorts.include? params[:sort_by]

    if params.has_key?(:order)
      order = params[:order].upcase if ['ASC','DESC'].include? params[:order].upcase
    end

    if params.has_key?(:sort_by) or params.has_key?(:per_page) or params.has_key?(:page)
      result_objects = Filter.all.order("#{sort_by} #{order}") \
        .page(params[:page]) \
        .per(params[:per_page])
      count = result_objects.total_count
    else
      result_objects = Filter.all
      count = result_objects.count
    end

    results  = CodeburnerUtil.pack_finding_count(result_objects)

    if params.has_key?(:sort_by) and params[:sort_by] == 'finding_count'
      results = results.sort_by { |hash| hash[:finding_count] }.reverse
    end

    render(:json => {count: count, results: results})
  end

  # START ServiceDiscovery
  # resource: filters.show
  # description: Show a filter
  # method: GET
  # path: /filter/:id
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: Filter ID
  #       location: url
  #       required: true
  #
  # response:
  #   name: filter
  #   description: a filter object
  #   type: object
  #   properties:
  #     id:
  #       type: integer
  #       description: filter ID
  #     service_id:
  #       type: integer
  #       descritpion: the service ID
  #     severity:
  #       type: integer
  #       description: severity to filter (0 - 3)
  #     fingerprint:
  #       type: string
  #       description: the SHA256 fingerprint to filter
  #     scanner:
  #       type: string
  #       description: a specific scanning software to filter
  #     description:
  #       type: string
  #       description: finding description to filter
  #     detail:
  #       type: string
  #       description: finding detail text to filter
  #     file:
  #       type: string
  #       description: file name to filter
  #     line:
  #       type: string
  #       description: line number or range to filter
  #     code:
  #       type: text
  #       description: the code snipper to filter
  # END ServiceDiscovery
  def show
    results = Filter.find(params[:id])

    render(:json => results)
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no filter with that id found}"}, :status => 404)
  end

  # START ServiceDiscovery
  # resource: filters.create
  # description: Create a filter
  # method: POST
  # path: /filter
  #
  # request:
  #   parameters:
  #     service_id:
  #       type: integer
  #       descritpion: service_id to filter
  #       location: body
  #       required: false
  #     severity:
  #       type: integer
  #       description: severity to filter
  #       location: body
  #       required: false
  #     fingerprint:
  #       type: string
  #       description: fingerprint to filter
  #       location: body
  #       required: false
  #     scanner:
  #       type: string
  #       description: scanner to filter
  #       location: body
  #       required: false
  #     description:
  #       type: string
  #       description: description to filter
  #       location: body
  #       required: false
  #     detail:
  #       type: string
  #       description: detail to filter
  #       location: body
  #       required: false
  #     file:
  #       type: string
  #       description: file name to filter
  #       location: body
  #       required: false
  #     line:
  #       type: string
  #       description: line number or range to filter
  #       location: body
  #       required: false
  #     code:
  #       type: text
  #       description: code snippet to filter
  #       location: body
  #       required: false
  #
  # response:
  #   name: filter
  #   description: a filter object
  #   type: object
  #   properties:
  #     $ref: filters.show.response
  # END ServiceDiscovery
  def create
    filter = Filter.new({
      :service_id => params[:service_id],
      :severity => params[:severity],
      :fingerprint => params[:fingerprint],
      :scanner => params[:scanner],
      :description => params[:description],
      :detail => params[:detail],
      :file => params[:file],
      :line => params[:line],
      :code => params[:code]
      })

    if filter.valid?
      filter.save
      filter.filter_existing!
      render(:json => filter.to_json)
    else
      render(:json => {error: filter.errors[:base]}, :status => 409)
    end
  end

  # START ServiceDiscovery
  # resource: filters.destroy
  # description: Delete a specific filter
  # method: DELETE
  # path: /filter/:id
  #
  # request:
  #   parameters:
  #     id:
  #       type: integer
  #       descritpion: Filter ID
  #       location: url
  #       required: true
  #
  # response:
  #   name: result
  #   description: result success or error w/ msg
  # END ServiceDiscovery
  def destroy
    return render(:json => {error: "bad request"}, :status => 400) unless params.has_key?(:id)

    filter = Filter.find(params[:id])
    filtered_by = Finding.filtered_by(filter.id)
    service_ids = []
    filtered_by.each {|finding| service_ids << finding.service_id}
    service_ids.uniq.each do |service_id|
      CodeburnerUtil.update_service_stats service_id
    end

    filtered_by.update_all(status: 0, filter_id: nil)

    filter.destroy!

    Filter.all.each do |each_filter|
      each_filter.filter_existing!
    end

    render(:json => {result: "success"})
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "record not found for id = #{params[:id]}"}, :status => 404)
  end

end
