'use strict'

class Codeburner.Collections.Filter extends Backbone.PageableCollection
  model: Codeburner.Models.Filter
  url: '/api/filter'
  mode: 'server'
  state:
    pageSize: 10
    sortKey: 'finding_count'
    order: 1

  parseState: (data) ->
    totalRecords: data.count

  parseRecords: (data) ->
    data.results
