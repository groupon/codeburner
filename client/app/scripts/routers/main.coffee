'use strict'

class Codeburner.Routers.Main extends Backbone.Router
  initialize: (serviceCollection) ->
    @findingCollection = new Codeburner.Collections.Finding
    @findingListView = new Codeburner.Views.FindingList @findingCollection, serviceCollection

    @burnCollection = new Codeburner.Collections.Burn
    @burnListView = new Codeburner.Views.BurnList @burnCollection, serviceCollection

    @filterCollection = new Codeburner.Collections.Filter
    @filterListView = new Codeburner.Views.FilterList @filterCollection, serviceCollection

    @statsView = new Codeburner.Views.Stats serviceCollection

  routes:
    'finding?*queryString': 'findingAction'
    'finding': 'findingAction'
    'filter': 'filterAction'
    'stats': 'statsAction'
    '*actions': 'defaultAction'

  findingAction: (query) ->
    do @burnListView.clearRefreshInterval
    do @burnListView.undelegateEvents
    do @filterListView.undelegateEvents
    do @statsView.undelegateEvents
    if query?
      do @findingCollection.resetFilter
      @findingCollection.filters = _.extend @findingCollection.filters, Codeburner.Utilities.parseQueryString(query)
      do @findingCollection.changeFilter
    do @findingListView.render

  filterAction: ->
    do @burnListView.clearRefreshInterval
    do @burnListView.undelegateEvents
    do @findingListView.undelegateEvents
    do @statsView.undelegateEvents
    do @filterListView.render

  statsAction: ->
    do @burnListView.clearRefreshInterval
    do @burnListView.undelegateEvents
    do @findingListView.undelegateEvents
    do @filterListView.undelegateEvents
    do @statsView.render

  defaultAction: ->
    do @findingListView.undelegateEvents
    do @filterListView.undelegateEvents
    do @statsView.undelegateEvents
    do @burnListView.render

$ ->
  serviceCollection = new Codeburner.Collections.Service
  serviceCollection.fetch().done =>
    window.router = new Codeburner.Routers.Main serviceCollection
    do $.material.init
    do Backbone.history.start
