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

  renderUserDetail: (id) ->
    $('#user-detail').html JST["app/scripts/templates/user/#{id}.ejs"]
      user: Codeburner.User

  render: ->
    do @delegateEvents
    @$el.html JST['app/scripts/templates/user_page.ejs']
