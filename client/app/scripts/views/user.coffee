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

Codeburner.Views.User = Backbone.View.extend
  el: $('#content')
  tokens: []
  repos: []
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

      @renderUserDetail id

    'click #generate-token': (e) ->
      do $('#token-dialog').show
      do $('#token-dialog').modal

    'click #generate-token-confirm': (e) ->
      name = $('#token-name').val()

      unless name
        Codeburner.Utilities.alert "token name required"

      Codeburner.Utilities.postRequest '/api/token', {'name': name}, ((data) ->
        window.router.userView.renderUserDetail 'tokens'
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'click #add-repo': (e) ->
      do Codeburner.Utilities.selectRepo
      do $('#add-repo-dialog').show
      do $('#add-repo-dialog').modal

    'click #add-repo-confirm': (e) ->
      repo = $('#select-repo').val()

      if repo.length > 1
        Codeburner.Utilities.postRequest "/api/user/#{Codeburner.User.id}/repos", {'repo': repo}, ((data) ->
          window.router.userView.renderUserDetail 'repos'
        ), (data) ->
          Codeburner.Utilities.alert "#{data.responseJSON.error}"

    'click .delete-repo-btn': (e) ->
      repo = $(e.target).closest('.delete-repo-btn').data 'repo'

      Codeburner.Utilities.deleteRequest "/api/user/#{Codeburner.User.id}/repos/#{repo}", ((data) ->
        window.router.userView.renderUserDetail 'repos'
      ), (data) ->
        Codeburner.Utilities.alert "#{data.responseJSON.error}"


  renderUserDetail: (id) ->
    switch id
      when 'tokens'
        Codeburner.Utilities.getRequest "/api/token", ((data) =>
          tokens = data
          $('#user-detail').html JST["app/scripts/templates/user/tokens.ejs"]
            user: Codeburner.User
            tokens: data
        ), (data) ->
          Codeburner.Utilities.alert "#{data.responseJSON.error}"

      when 'repos'
        Codeburner.Utilities.getRequest "/api/user/#{Codeburner.User.id}/webhooks", ((data) =>
          $('#user-detail').html JST["app/scripts/templates/user/repos.ejs"]
            user: Codeburner.User
            repos: data
        ), (data) ->
          Codeburner.Utilities.alert "#{data.responseJSON.error}"

    $('#user-detail').html JST["app/scripts/templates/user/#{id}.ejs"]
      user: Codeburner.User
      tokens: @tokens
      repos: @repos

  render: ->
    do @delegateEvents
    @$el.html JST['app/scripts/templates/user_page.ejs']
      user: Codeburner.User
