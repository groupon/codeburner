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

Codeburner.Views.Settings = Backbone.View.extend
  el: $('#content')
  currentPage: 1
  settigs: {}
  initialize: (@settings) ->
    do @undelegateEvents

  events:
    'click .settings-list': (e) ->
      target = $(e.target).parent()
      id = target.data 'id'
      selected = target.prop 'selected'

      unless selected
        $('.settings-list').removeClass 'highlight-settings-row'
        $('.settings-list').prop 'selected', false
        target.addClass 'highlight-settings-row'
        target.prop 'selected', true

      @renderSettingsDetail id

    'click #admin-submit': (e) ->
      newAdmins = {
        'admins': []
      }
      for admin in $('#admin-list').val().split(",")
        newAdmins.admins.push admin

      Codeburner.Utilities.postRequest '/api/settings/admin', newAdmins, ((data) =>
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'click #settings-submit': (e) ->
      category = $('#category').data 'id'
      newSettings = {
        'settings': {
          "#{category}": {}
        }
      }

      for setting in $('.input-setting')
        valueString = $(setting).val()

        if valueString.indexOf(",")
          value = valueString.replace(/\s+/g, '').split(",")
        else
          value = valueString

        if $(setting).parent().parent().is("span")
          heading = $(setting).parent().parent().data("id")
          newSettings.settings[category][heading] = {} unless newSettings.settings[category].hasOwnProperty(heading)
          _.extend(newSettings.settings[category][heading], {"#{$(setting).data("id")}":value})
        else
          _.extend(newSettings.settings[category], {"#{$(setting).data("id")}":value})

      Codeburner.Utilities.postRequest '/api/settings', newSettings, ((data) =>
        _.extend(@settings, newSettings.settings)
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

  renderAdminSelect: ->
    $('#admin-list').selectize(
      valueField: 'login'
      labelField: 'login'
      searchField: ['fullname', 'login']
      plugins: ['remove_button']
      delimiter: ','
      copyClassesToDropdown: true
      closeAfterSelect: true
      addPrecedence: true
      create: false
      render:
        option: (item, escape) ->
          html = "<div><img src=\"#{item.avatar_url}\" style=\"height:18px;\">&nbsp;&nbsp;"
          if item.fullname
            html += "#{item.fullname}&nbsp;(#{item.login})</div>"
          else
            html += "#{item.login}</div>"

          return html

      load: (query, callback) ->
        return callback() unless query.length
        $.ajax(
          url: "https://api.github.com/search/users?q=\"#{encodeURIComponent(query)}\"+in:fullname"
          type: 'GET'
          headers:
            'Accept': 'application/vnd.github.v3.text-match+json'
          error: () ->
            callback()

          success: (res) ->
            for user in res.items
              name = user.text_matches.filter((match) =>
                match.property == 'name'
              )
              if name.length > 0
                user.fullname = name[0].fragment
            callback(res.items)
        )
    )

  renderSettingsDetail: (id) ->
    $('#settings-detail').html JST["app/scripts/templates/settings/#{id}.ejs"]
      settings: @settings[id]

    if id == 'admin'
      Codeburner.Utilities.getRequest "/api/settings/admin", ((data) =>
        admins = []
        for admin in data
          admins.push admin.name

        $('#admin-list').val admins.join()
        do @renderAdminSelect
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

  render: ->
    do @delegateEvents
    Codeburner.Utilities.getRequest "/api/settings", ((data) =>
      @settings = data
      @$el.html JST['app/scripts/templates/settings_page.ejs']
    ), (data) ->
      Codeburner.Utilities.alert "#{data.responseJSON.error}"
