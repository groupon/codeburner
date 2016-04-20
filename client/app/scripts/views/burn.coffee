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
  initialize: (@burnCollection, @serviceCollection) ->
    do @undelegateEvents

  events:
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
      $('#select-repo').selectize(
        valueField: 'full_name'
        labelField: 'full_name'
        searchField: [ 'name', 'html_url', 'full_name' ]
        create: false
        render:
          option: (item, escape) ->
            html = '<div>' +
              '<span class="title">' +
                '<span class="name"><span class="octicon ' + if item.fork then 'oction-repo-forked' else 'octicon-repo' + '"></span> ' + escape(item.name) + '</span>' +              '<span class="by">' + escape(item.owner.login) + '</span>' +
              '</span>' +
              '<span class="description">' + escape(item.description) + '</span>' +
              '<ul class="meta">' +
                '<li class="language"><span class="octicon octicon-code"></span> ' + escape(item.language) + '</li>' +
                '<li class="stargazers"><span class="octicon octicon-star"></span><span> ' + escape(item.stargazers_count) + '</span> </li>' +
                '<li class="forks"><span class="octicon octicon-repo-forked"></span><span> ' + escape(item.forks) + '</span> </li>' +
              '</ul>' +
            '</div>'

            return html

        score: (search) ->
          score = this.getScoreFunction search
          return (item) ->
            return score(item) * (1 + Math.min(item.stargazers_count / 100, 1))

        load: (query, callback) ->
          return callback() unless query.length
          Codeburner.Utilities.getRequest "/api/github/search/repos?q=#{encodeURIComponent(query)}", ((data) ->
            callback(data.items)
          ), (data) ->
            do callback
      )
      do $('#submitDialog').show
      do $('#submitDialog').modal

    'click #submit-burn': ->
      postData = {'service_name': $('#select-repo').val()}
      if $('#revision').val()
        postData['revision'] = $('#revision').val().trim()
      if $('#notify').val()
        postData['notify'] = $('#notify').val().trim()
      Codeburner.Utilities.postRequest '/api/burn', postData, ((data) =>
        @serviceCollection.fetch().done =>
          do @renderBurns
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'click .burn-show-findings': (e) ->
      burn_id = $(e.target).closest('.burn-show-findings').data 'id'
      service_id = $(e.target).closest('.burn-show-findings').data 'service'
      window.router.navigate "#findings?burn_id=#{burn_id}&service_id=#{service_id}", {trigger: true, replace: true}

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

  renderStats: ->
    url = '/api/stats'
    Codeburner.Utilities.getRequest url, (data) ->
      $('#burn_stats').html JST['app/scripts/templates/burn_stats.ejs']
        stats: data

  renderBurns: ->
    @burnCollection.getPage(@currentPage).done =>
      $('#burn_list').html JST['app/scripts/templates/burn.ejs']
        burns: @burnCollection.models
        services: @serviceCollection.models

      Codeburner.Utilities.renderPaginater @currentPage, @burnCollection.state.totalPages, @burnCollection.state.totalRecords, @burnCollection.state.pageSize

  clearRefreshInterval: ->
    clearInterval @burnRefreshInterval

  render: ->
    do @delegateEvents
    @$el.html JST['app/scripts/templates/burn_page.ejs']
    do @renderStats
    do @renderBurns

    $("body").tooltip({ selector: '[data-toggle=tooltip]' })

    @burnRefreshInterval = setInterval =>
      do @renderStats
      do @renderBurns
    , window.constants.refresh_interval
