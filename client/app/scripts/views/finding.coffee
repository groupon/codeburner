'use strict'

Codeburner.Views.FindingList = Backbone.View.extend
  el: $('#content')
  currentPage: 1
  lastFindingHighlighted: null
  initialize: (@collection, @serviceCollection) ->
    do @undelegateEvents
  events:
    'click .toggle-checkbox': (e) ->
      parent = $(e.target).parent()
      checkBox = parent.find('input[name=finding_checkbox]')
      checkBox.prop 'checked', !checkBox.prop('checked')

    'click .show-detail': (e) ->
      target = $(e.target).parent()
      id = target.data 'id'

      if @lastFindingHighlighted?
        @lastFindingHighlighted.removeClass 'highlight-row'
        @lastFindingHighlighted.prop 'selected', false

      target.addClass 'highlight-row'
      target.prop 'selected', true
      @lastFindingHighlighted = target

      $('#detail').html JST['app/scripts/templates/detail.ejs']
        id: id
        model: @collection.get id
        services: @serviceCollection.models
        burnList: @collection.burnList

      if $('#fingerprint-span').height() > 20
        $('#fingerprint-span').html @collection.get(id).get('fingerprint').substring(0,36) + '<b style="font-size: 16px;"> <a href="javascript:void(0)" id="truncate-fingerprint">...</a></b>'

    'click .header': (e) ->
      if @collection.state.sortKey is e.target.dataset.id
        @collection.state.order *= -1
      else
        @collection.state.order = -1

      @collection.state.sortKey = e.target.dataset.id
      do @renderFindings

    'click .pagination': (e) ->
      @currentPage = parseInt e.target.dataset.page, 10
      do @renderFindings

    'click #hide-issue': ->
      id = $('.highlight-row:selected').data 'id'
      if @collection.get(id).get('status') is 1
        status = 0
      else
        status = 1

      Codeburner.Utilities.putRequest "/api/finding/#{id}?status=#{status}", ((data) =>
        do @renderFindings
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'click #publish-btn': ->
      $('#publish-form').trigger("reset")
      $('#publish-dialog-body').show()
      $('#publish-dialog-spinner').hide()
      $('#publish-dialog-results').hide()
      @setTicketOption $('input[name=ticket-option]:radio:checked').val()
      do $('#publishDialog').modal

    'click #publish-submit': ->
      method = $('input[name=ticket-option]:radio:checked').val()
      project = $('#project-name').val()
      id = $('.highlight-row:selected').data 'id'

      $('#publish-dialog-body-jira').hide()
      $('#publish-submit').prop 'disabled', true
      $('#publish-dialog-body').hide()
      $('#publish-dialog-spinner').show()

      Codeburner.Utilities.putRequest "/api/finding/#{id}/publish?method=#{method}&project=#{project}", ((result) =>
        $('#publish-dialog-spinner').hide()
        $('#publish-dialog-results').show()
        $('#publish-dialog-results').html JST['app/scripts/templates/finding_publish_results.ejs']
          ticket: result.ticket
          link: result.link
        do @renderFindings
      ), (data) ->
        $('#publishDialog').modal('hide')
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'change input[name=ticket-option]': ->
      @setTicketOption $('input[name=ticket-option]:radio:checked').val()

    'change #show-publish': ->
      if $('#show-publish').prop 'checked'
        @collection.filters.status.push '2'
      else
        @collection.filters.status = _.uniq(_.without @collection.filters.status, '2')

      do @collection.changeFilter
      do @renderFindings

    'change #show-hidden': ->
      if $('#show-hidden').prop 'checked'
        @collection.filters.status.push '1'
      else
        @collection.filters.status = _.uniq(_.without @collection.filters.status, '1')

      do @collection.changeFilter
      do @renderFindings

    'change #show-filtered': ->
      if $('#show-filtered').prop 'checked'
        @collection.filters.status.push '3'
      else
        @collection.filters.status = _.uniq(_.without @collection.filters.status, '3')

      do @collection.changeFilter
      do @renderFindings

    'keyup #filter': ->
      $('.service-list').removeClass 'highlight-service-row'
      $('.service-list').prop 'selected', false
      @renderServiceList $('#filter').val()

    'click .service-list': (e) ->
      target = $(e.target).parent()
      id = target.data 'id'
      selected = target.prop 'selected'

      if selected
        target.removeClass 'highlight-service-row'
        target.prop 'selected', false
      else
        $('.service-list').removeClass 'highlight-service-row'
        $('.service-list').prop 'selected', false
        target.addClass 'highlight-service-row'
        target.prop 'selected', true

      do @collection.resetFilter
      unless selected
        @collection.filters.service_id = id
        Backbone.history.navigate "finding?service_id=#{id}"
      else
        @collection.filters.service_id = null
        Backbone.history.navigate "finding"

      do @collection.changeFilter
      do @renderFindings

    'click #filter-btn': ->
      id = $('#filter-btn').data 'finding-id'
      model = @collection.get id
      if model.get('code')
        code = model.get('code')
      else
        code = ''

      $('#filter-dialog-body').html JST['app/scripts/templates/add_filter.ejs']
        id: id
        model: model
        code: code
        service_name: @serviceCollection.models[_.findIndex(@serviceCollection.models, {id: model.get('service_id')})].get('pretty_name')
        display_severity: window.constants.display_severity[model.get('severity')]

      do $('#filterModal').modal

    'click #create-filter-btn': ->
      data = {}
      model = @collection.get $('#finding-id').val()
      checkboxes = $('#filter-dialog-body input:checkbox:checked')
      checked = []
      if checkboxes.length < 9 or confirm 'Are you sure?'
        for item in checkboxes
          input = $(item).parent().parent().parent().find('input:text')
          if input.hasClass 'form-control'
            value = do input.val
          else
            input = $(item).parent().parent().parent().find('code')
            value = input.innerHTML

          name = input.attr 'name'
          data[name] = value
          for field in ['service_id', 'severity', 'detail', 'code']
            if name is field
              checked.push field

        for i in checked
          data[i] = model.get(i)

        Codeburner.Utilities.postRequest '/api/filter', data, ((res) =>
          $('#filterModal').modal 'hide'
          do @renderFindings
        ), (res) ->
          Codeburner.Utilities.alert "#{res.responseJSON.error}"

    'click #truncate-fingerprint': (e) ->
      $(e.target).parent().parent().html $(e.target).parent().parent().data 'fingerprint'

    'keyup .validated': (e) ->
      $('.floating-label').removeClass 'invalid'
      if $('.validated:invalid').length > 0
        $('#publish-submit').prop 'disabled', true
      else
        $('#publish-submit').prop 'disabled', false

    'click .validated': (e) ->
      $('.floating-label').removeClass 'invalid'
      if e.target.validity.valid
        $(e.target).parent().find('.floating-label').removeClass 'invalid'
      else
        $(e.target).parent().find('.floating-label').addClass 'invalid'

  setTicketOption: (type) ->
    if type == "jira"
      $('#publish-dialog-body-jira').html JST['app/scripts/templates/finding_publish_jira.ejs']
      $('#publish-submit').prop 'disabled', true
      $('#publish-dialog-body-jira').show(400)
    else
      $('#publish-dialog-body-jira').hide()
      $('#publish-submit').prop 'disabled', false

  filterServiceList: (services, filter) ->
    if filter
      regex = new RegExp "^#{filter.replace('*','.*').toLowerCase()}.*"
      _.filter services, (element) ->
        element.get('pretty_name').toLowerCase().match(regex)
    else
      services

  renderServiceList: (query) ->
    $('.service-list').removeClass 'highlight-service-row'
    $('.service-list').prop 'selected', false

    $('#service-list').html JST['app/scripts/templates/service_list.ejs']
      services: @filterServiceList @serviceCollection.models, query

    if @collection.filters.service_id
      selectedRow = $(".service-list[data-id='#{@collection.filters.service_id}']")
      selectedRow.addClass 'highlight-service-row'
      selectedRow.prop 'selected', true

  updateBurnList: ->
      burns = []
      for model in @collection.models
        burns.push model.get('burn_id')

      Codeburner.Utilities.getRequest "/api/burn?id=#{_.uniq(burns).join(',')}", ((data) =>
        burnList = {}
        for result in data.results
          burnList[result.id] = { 'revision':result.revision, 'repoUrl':result.repo_url }
        @collection.burnList = burnList
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

  renderFindings: ->
    if @collection.filters.service_id
      @service_name = @serviceCollection.models[_.findIndex(@serviceCollection.models, {id: parseInt(@collection.filters.service_id)})].get('pretty_name')
    else
      @service_name = null

    @collection.getPage(@currentPage).done =>
      @lastHighlighted = null
      $('#detail').html ''
      $('#finding-list').html JST['app/scripts/templates/finding.ejs']
        models: @collection.models
        burn_id: @collection.filters.burn_id
        service_name: @service_name
        service_id: @collection.filters.service_id
        filtered_by: @collection.filters.filtered_by

      sortBy = $("[data-id='#{@collection.state.sortKey}']").find('span')
      sortBy.removeClass 'hidden'
      if @collection.state.order is 1
        sortBy.addClass 'dropup'

      Codeburner.Utilities.renderPaginater @currentPage, @collection.state.totalPages, @collection.state.totalRecords, @collection.state.pageSize
      do @updateBurnList

  render: ->
    do @delegateEvents
    @$el.html JST['app/scripts/templates/finding_page.ejs']
      filtered: '3' in @collection.filters.status
      publish: '2' in @collection.filters.status
      hidden: '1' in @collection.filters.status
    do @renderServiceList
    do @renderFindings
    $("body").tooltip({ selector: '[data-toggle=tooltip]' })
