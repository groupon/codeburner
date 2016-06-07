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

Codeburner.Views.Stats = Backbone.View.extend
  el: $('#content')
  availableRange: {}
  baseUrl: "/api"
  resolutionSlider: document.getElementById('resolution')
  initialize: (@repoCollection) ->
    do @undelegateEvents

  events:
    'click #redraw': (e) ->
      $('#redraw').hide()
      @drawCharts(true)

    'change #start-date': (e, date) ->
      $('#end-date').bootstrapMaterialDatePicker('setMinDate', moment(date).add(1, 'day'))

    'change .datepicker': (e) ->
      startDate = moment($('#start-date').val(), "MMMM DD, YYYY")
      endDate = moment($('#end-date').val() , "MMMM DD, YYYY")
      Codeburner.Utilities.getRequest @baseUrl+"/stats/history/resolution?start_date=#{startDate.toJSON()}&end_date=#{endDate.toJSON()}", ((data) =>
        @resolutionSlider.noUiSlider.set(data)
        $('#redraw').show()
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'click .selectize-control': (e) ->
      $('#repo-list')[0].selectize.clear()

    'change #repo-list': (e) ->
      repo = $('#repo-list').val()
      if repo == '-1'
        @baseUrl = "/api"
      else
        @baseUrl = "/api/repo/#{repo}"

      unless repo == ''
        Codeburner.Utilities.getRequest @baseUrl+"/stats/history/range", ((data) =>
          startDatePicker = $('#start-date')
          endDatePicker = $('#end-date')

          startDatePicker.bootstrapMaterialDatePicker('setMinDate', moment(data.start_date))
          startDatePicker.bootstrapMaterialDatePicker('setMaxDate', moment(data.end_date).subtract(1, 'day'))
          startDatePicker.bootstrapMaterialDatePicker('setDate', moment(data.start_date))
          startDatePicker.val(moment(data.start_date).format('MMMM DD, YYYY'))
          endDatePicker.bootstrapMaterialDatePicker('setMinDate', moment(data.start_date).add(1, 'day'))
          endDatePicker.bootstrapMaterialDatePicker('setMaxDate', moment())
          endDatePicker.bootstrapMaterialDatePicker('setDate', moment())
          endDatePicker.val(moment().format('MMMM DD, YYYY'))

          @resolutionSlider.noUiSlider.set(data.resolution)
          @drawCharts(true)
          $('#redraw').hide()
        ), (data) ->
          Codeburner.Utilities.alert "#{data.responseJSON.error}"

  renderCharts: ->
    Codeburner.Utilities.getRequest @baseUrl+"/stats/history/range", ((data) =>
      @availableRange = data
      $('.datepicker').removeClass 'empty'
      $('#end-date').bootstrapMaterialDatePicker({time: false, format: 'MMMM DD, YYYY', minDate: moment(data.start_date), currentDate: moment(), maxDate: moment()})
      $('#start-date').bootstrapMaterialDatePicker({time:false, format: 'MMMM DD, YYYY', currentDate: moment(data.start_date), minDate: moment(data.start_date), maxDate: moment().subtract(1, 'day')})

      # for some reason this HAS to be set by document.getElementById right here or else nouislider.js throws errors
      @resolutionSlider = document.getElementById('resolution')

      noUiSlider.create(@resolutionSlider, {
        start: data.resolution,
        snap: true,
        range: {
          'min': 60,
          '6.6%': 300,
          '13.3%': 600,
          '20.0%': 900,
          '26.6%': 1800,
          '33.3%': 3600,
          '40.0%': 7200,
          '46.6%': 14400,
          '53.3%': 21600,
          '60.0%': 43200,
          '66.6%': 86400,
          '73.3%': 259200,
          '80.0%': 604800,
          '86.6%': 1209600,
          'max': 2592000
        }
      })

      @resolutionSlider.noUiSlider.on('update', (value) =>
        $('#resolution-label').html moment.duration(value*1000).humanize()
        $('#redraw').show()
      )

      $('#redraw').hide()
      google.load('visualization', '1', {'callback': @drawCharts, 'packages':['corechart']})
    ), (data) ->
      Codeburner.Utilities.alert "#{data.responseJSON.error}"

  drawCharts: (fromClick) ->
    availableRange = window.router.statsView.availableRange
    startDate = moment($('#start-date').val(), "MMMM DD, YYYY")
    endDate = moment($('#end-date').val() , "MMMM DD, YYYY")
    resolution = window.router.statsView.resolutionSlider.noUiSlider.get()
    urlString = "?"

    unless startDate.dayOfYear() == moment(availableRange.start_date).dayOfYear()
      urlString = urlString + "&start_date=#{startDate.toJSON()}"

    unless endDate.dayOfYear() == moment().dayOfYear()
      urlString = urlString + "&end_date=#{endDate.toJSON()}"

    if fromClick
      urlString = urlString + "&resolution=#{resolution}"

    window.router.statsView.drawBurnChart urlString
    window.router.statsView.drawFindingHistory urlString
    do window.router.statsView.drawFindingStats

  drawFindingStats: ->
    Codeburner.Utilities.getRequest window.router.statsView.baseUrl+"/stats", ((data) =>
      dataTable = new google.visualization.DataTable
      dataTable.addColumn('string', 'Type')
      dataTable.addColumn('number', 'Count')

      dataTable.addRow ['Open', data.open_findings]
      dataTable.addRow ['Filtered', data.filtered_findings]
      dataTable.addRow ['Published', data.published_findings]
      dataTable.addRow ['Hidden', data.hidden_findings]

      options =
        title: 'Current Findings',
        pieHole: 0.3,
        slices:
          0: {color: '#dc3912'}
          1: {color: '#3366cc'}
          2: {color: '#ff9900'}
          3: {color: '#109618'}

      chart = new google.visualization.PieChart(@$('#finding_breakdown').get(0))
      chart.draw dataTable, options
    ), (data) ->
      Codeburner.Utilities.alert "#{data.responseJSON.error}"

  drawBurnChart: (urlString) ->
    $('#burn_history').html '<center><img class="center" alt="spinner" src="/images/loader.gif"></center>'

    Codeburner.Utilities.getRequest window.router.statsView.baseUrl+"/stats/burns"+urlString, ((data) =>
      dataTable = new google.visualization.DataTable
      dataTable.addColumn('date', 'Date')
      dataTable.addColumn('number', 'New Burns')
      dataTable.addRows data.map((stat) =>
        [new Date(stat[0]), stat[1]]
      )

      options =
        title: 'Burn History',
        animation: {startup: true, duration: 750}

      $('#burn_history').html ''
      chart = new google.visualization.ColumnChart(@$('#burn_history').get(0))
      chart.draw dataTable, options
    ), (data) ->
      $('#burn_history').html ''
      Codeburner.Utilities.alert "#{data.responseJSON.error}"

  drawFindingHistory: (urlString) ->
    $('#finding_history').html  '<center><img class="center" alt="spinner" src="/images/loader.gif"></center>'

    Codeburner.Utilities.getRequest window.router.statsView.baseUrl+"/stats/history"+urlString, ((data) =>
      dataTable = new google.visualization.DataTable
      dataTable.addColumn('datetime', 'Date')
      dataTable.addColumn('number', 'Open')
      dataTable.addColumn('number', 'Filtered')
      dataTable.addColumn('number', 'Published')
      dataTable.addColumn('number', 'Hidden')
      dataTable.addColumn('number', 'Total')

      for i in [0...data.open_findings.length]
        row = []
        row.push new Date(data.open_findings[i][0]), data.open_findings[i][1], data.filtered_findings[i][1], data.published_findings[i][1], data.hidden_findings[i][1], data.total_findings[i][1]
        dataTable.addRow row

      options =
        title: 'Finding History',
        curveType: 'function',
        hAxis: {format: 'MM/dd/yyyy HH:mm:ss'},
        animation: {startup: true, duration: 750},
        explorer: {}
        series:
          0: {color: '#dc3912'}
          1: {color: '#3366cc'}
          2: {color: '#ff9900'}
          3: {color: '#109618'}

      $('#finding_history').html ''
      chart = new google.visualization.LineChart(@$('#finding_history').get(0))
      chart.draw dataTable, options
    ), (data) ->
      $('#finding_history').html ''
      Codeburner.Utilities.alert "#{data.responseJSON.error}"

  render: ->
    do @delegateEvents
    @$el.html JST['app/scripts/templates/stats_page.ejs']
      repos: @repoCollection.models
    @repoSelect = $('#repo-list').selectize({lockOptgroupOrder: true})
    do @renderCharts
