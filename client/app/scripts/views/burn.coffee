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
'use strict'

Codeburner.Views.BurnList = Backbone.View.extend
  el: $('#content')
  currentPage: 1
  logSources: {}
  logSource: null
  repoSelect: null
  initialize: (@burnCollection, @repoCollection) ->
    do @undelegateEvents

  events:
    # 'click .selectize-control': (e) ->
    #   $('#repo-list')[0].selectize.clear()

    'click .header': (e) ->
      if @burnCollection.state.sortKey is e.target.dataset.id
        @burnCollection.state.order *= -1
      else
        @burnCollection.state.order = -1

      if @burnCollection.state.order is -1
        $(e.target).find('.sorting').addClass 'dropup'
      else
        $(e.target).find('.sorting').removeClass 'dropup'

      $('.sorting').addClass 'hidden'
      $(e.target).find('.sorting').removeClass 'hidden'

      @burnCollection.state.sortKey = e.target.dataset.id
      do @renderBurns

    'click .pagination': (e) ->
      @currentPage = parseInt e.target.dataset.page, 10
      do @renderBurns

    'click #submit-burn-btn': ->
      $('#burn-submit-body').html JST['app/scripts/templates/burn_submit.ejs']

      do Codeburner.Utilities.selectRepo
      do $('#submitDialog').show
      do $('#submitDialog').modal

    'click #submit-burn': ->
      postData =
        'repo_name': $('#select-repo').val()
        'branch': $('#select-branch').val()

      if $('#notify').val()
        postData['notify'] = $('#notify').val().trim()

      Codeburner.Utilities.postRequest '/api/burn', postData, ((data) =>
        @repoCollection.fetch().done =>
          do @renderBurns
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'click .burn-show-findings': (e) ->
      burnDom = $(e.target).closest('.burn-show-findings')
      burn_id = burnDom.data 'id'
      repo_id = burnDom.data 'repo'
      branch = burnDom.data 'branch'

      window.router.navigate "#findings?repo_id=#{repo_id}&burn_id=#{burn_id}&branch=#{branch}&only_current=false", {trigger: true, replace: true}

    'click .burn-reignite': (e) ->
      burn_id = $(e.target).closest('.burn-reignite').data 'id'
      repo_id = $(e.target).closest('.burn-reignite').data 'repo'

      revision = @burnCollection.get(burn_id).get 'revision'
      name = @repoCollection.get(repo_id).get 'name'

      Codeburner.Utilities.confirm "Are you sure you want to rescan ``<strong>#{name}</strong> revision #{revision}?", ((data) ->
        Codeburner.Utilities.getRequest "/api/burn/#{burn_id}/reignite", ((data) =>
          do window.router.burnListView.renderBurns
        ), (data) =>
          Codeburner.Utilities.alert "#{data.responseJSON.error}"
      ), (data) ->
        do window.router.burnListView.renderBurns

    'keyup .validated': (e) ->
      $('.floating-label').removeClass 'invalid'
      if $('.validated:invalid').length > 0
        $('#submit-burn').prop 'disabled', true
      else
        $('#submit-burn').prop 'disabled', false

    'click .validated': (e) ->
      $('.floating-label').removeClass 'invalid'
      if e.target.validity.valid
        $(e.target).parent().find('.floating-label').removeClass 'invalid'
      else
        $(e.target).parent().find('.floating-label').addClass 'invalid'

    'click .burn-toggle-log': (e) ->
      $('[data-toggle="tooltip"]').tooltip('hide')
      target = $(e.target).closest('.burn-toggle-log')
      burnId = target.data 'id'
      burn = @burnCollection.get(burnId).attributes
      logSpan = target.closest('.burn-list-item').find('.burn-log')
      button = $("button.burn-toggle-log[data-id=#{burnId}]")

      if logSpan.is(':visible')
        $("button.burn-toggle-log").removeClass('btn-highlight')

        logSpan.slideUp(300)
        logSpan.html ""

        if @logSource
          @logSource.close()
          delete @logSource
          @logSource = null

        do @burnCollection.resetFilter
        do @setRefreshInterval
        do @renderBurns
      else
        $('#burn-pause-alert').show()
        do @clearRefreshInterval

        $("button.burn-toggle-log").removeClass('btn-highlight')
        button.addClass('btn-highlight')

        allLogSpans = target.closest('.container').find('.burn-log')
        allLogSpans.slideUp(300)

        unless burn.status == 'done' or burn.status == 'failed'
          @logSource = new EventSource("api/burn/#{burnId}/livelog")

          @logSource.addEventListener('message', (e) ->
            logSpan.append "#{e.data}\n"
            logSpan.scrollTop logSpan[0].scrollHeight
          , false)

          @logSource.addEventListener('error', (e) ->
            e.srcElement.close()
            window.router.burnListView.burnCollection.getPage(window.router.burnListView.currentPage).done =>
              burn = window.router.burnListView.burnCollection.get(burnId).attributes
              $(".burn-status[data-id=#{burn.id}]").html "&nbsp;#{burn.status}"
              $(".burn-done-buttons[data-id=#{burn.id}]").fadeIn(500)
          , false)
        else
          Codeburner.Utilities.getRequest "/api/burn/#{burnId}/log", ((data) =>
            logSpan.html data.log
            logSpan.scrollTop logSpan[0].scrollHeight
          ), (data) =>
            Codeburner.Utilities.alert "#{data.responseJSON.error}"

        logSpan.slideDown(300)

    'click #resume-burn-updates': (e) ->
      $('#burn-pause-alert').slideUp(300)
      do @burnCollection.resetFilter
      do @setRefreshInterval

      $(e.target).closest('.container').find('.burn-log').slideUp(300)

      do @renderBurns

    'change #repo-list': (e) ->
      $('#burn_list').hide()
      do @renderBurns

  renderBurns: ->
    repoId = null
    val = parseInt $('#repo-list').val()
    switch val
      when -1
        repoId = null
      when -2
        repoId = Codeburner.User.repos.join(',')
      else
        repoId = val

    @burnCollection.filters.repo_id = repoId
    do @burnCollection.changeFilter

    @burnCollection.getPage(@currentPage).done =>
      $('#burn_list').html JST['app/scripts/templates/burn.ejs']
        burns: @burnCollection.models
        repos: @repoCollection.models
        tagIdentifiers: [ '-', '.', '_' ]

      $('#burn_list').fadeIn(500)

      Codeburner.Utilities.renderPaginater @currentPage, @burnCollection.state.totalPages, @burnCollection.state.totalRecords, @burnCollection.state.pageSize

      if @burnCollection.filters.id
        button = $("button.burn-toggle-log[data-id=#{@burnCollection.filters.id}]")
        button.click()

  clearRefreshInterval: ->
    clearInterval @burnRefreshInterval

  setRefreshInterval: ->
    @burnRefreshInterval = setInterval =>
      do @renderBurns
    , window.constants.refresh_interval

  render: ->
    do @delegateEvents
    @$el.html JST['app/scripts/templates/burn_page.ejs']
     repos: @repoCollection.models

    $('#repo-list').selectize ->
      valueField: 'full_name'
      labelField: 'full_name'
      searchField: [ 'name', 'html_url', 'full_name' ]
      create: false

    do @renderBurns
    do @setRefreshInterval
