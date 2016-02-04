'use strict'

class Codeburner.Collections.Service extends Backbone.Collection
  model: Codeburner.Models.Service
  url: '/api/service'
  mode: 'client'

  parse: (data) ->
    data.results
