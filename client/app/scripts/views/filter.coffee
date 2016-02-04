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

Codeburner.Views.FilterList = Backbone.View.extend
  el: $('#content')
  currentPage: 1
  initialize: (@collection, @serviceCollection) ->
    do @undelegateEvents
  events:
    'click .pagination': (e) ->
      @currentPage = parseInt e.target.dataset.page, 10
      do @renderFilters

    'click #filter-delete-btn': (e) ->
      Codeburner.Utilities.confirm 'Are you sure you want to delete this filter?', (=>
        Codeburner.Utilities.deleteRequest "/api/filter/#{$(e.target).data('id')}", ((res) =>
          do @renderFilters
        ), (res) =>
          Codeburner.Utilities.alert "#{res.responseJSON.error}"
        ), ->


    'click #expand-filter': (e) ->
      detailBox = $(e.target).parent().parent().find('.collapse')
      detailBox.collapse('toggle')
      navIcon = $(e.target).html().substr(0, $(e.target).html().indexOf('<'))
      if navIcon == 'unfold_more'
        navIcon = 'unfold_less'
      else
        navIcon = 'unfold_more'

      $(e.target).html navIcon

    'click #link-findings': (e) ->
      filter_id = $(e.target).data 'id'
      window.router.navigate "finding?status=3&filtered_by=#{filter_id}", {trigger: true, replace: true}

  renderFilters: ->
    @collection.getPage(@currentPage).done =>
      $('#filter_list').html JST['app/scripts/templates/filter.ejs']
        models: @collection.models
        services: @serviceCollection.models

      Codeburner.Utilities.renderPaginater @currentPage, @collection.state.totalPages, @collection.state.totalRecords, @collection.state.pageSize

  render: ->
    do @delegateEvents
    @$el.html JST['app/scripts/templates/filter_page.ejs']
    do @renderFilters

