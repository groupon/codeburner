'use strict'

class Codeburner.Collections.Finding extends Backbone.PageableCollection
  model: Codeburner.Models.Finding
  url: '/api/finding'
  mode: 'server'
  state:
    pageSize: 25
    sortKey: 'severity'
    order: 1

  queryParams:
    status: '0'

  filters:
    status: ['0']

  parseState: (data) ->
    totalRecords: data.count

  parseRecords: (data) ->
    data.results

  resetFilter: ->
    @filters =
      status: ['0']
      burn_id: null
      service_id: null
      filtered_by: null

  changeFilter: ->
    query = []
    for key, value of @filters
      if $.isArray value
        data = value.join ','
      else
        data = value

      if data
        query.push "#{key}=#{data}"
        @queryParams[key] = data
      else
        @queryParams[key] = null
    Backbone.history.navigate "finding?#{query.join '&'}"
