'use strict'

class Codeburner.Collections.Burn extends Backbone.PageableCollection
  model: Codeburner.Models.Burn
  url: '/api/burn'
  mode: 'server'
  state:
    pageSize: 10
    sortKey: 'count'
    order: 1

  parseState: (data) ->
    totalRecords: data.count

  parseRecords: (data) ->
    data.results
