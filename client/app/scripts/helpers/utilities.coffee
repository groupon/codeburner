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
ARRAY_COLUMN = [
  'burn_id'
  'service_id'
  'status'
]
PAGINATION_RANGE = 6

Codeburner.Utilities =
  postRequest: (url, data, cb, error) ->
    $.ajax
      url: url
      type: 'POST'
      data: data
      headers:
        'Authorization': localStorage.getItem("authz")
      success: (res) ->
        cb res if cb?
      error: (res) ->
        error res if error?

  getRequest: (url, cb, error) ->
    $.ajax
      url: url
      type: 'GET'
      dataType: 'json'
      headers:
        'Authorization': localStorage.getItem("authz")
      success: (res) ->
        cb res if cb?
      error: (res) ->
        error res if error?

  putRequest: (url, cb, error) ->
    $.ajax
      url: url
      type: 'PUT'
      dataType: 'json'
      headers:
        'Authorization': localStorage.getItem("authz")
      success: (res) ->
        cb res if cb?
      error: (res) ->
        error res if error?

  deleteRequest: (url, cb, error) ->
    $.ajax
      url: url
      type: 'DELETE'
      dataType: 'json'
      headers:
        'Authorization': localStorage.getItem("authz")
      success: (res) ->
        cb res if cb?
      error: (res) ->
        error res if error?

  renderPaginater: (currentPage, totalPages, totalRows, pageSize) ->
    # Calculate the pagination
    total = totalPages
    current = currentPage
    paginater = {}

    if current - PAGINATION_RANGE / 2 <= 1
      left = 1
      right = Math.min PAGINATION_RANGE, total
    else
      left = current - PAGINATION_RANGE / 2
      right = current + PAGINATION_RANGE / 2
      if right > total
        right = total
        left = Math.max 1, right - PAGINATION_RANGE

    paginater.paginater = yes
    paginater.left = left
    paginater.right = right
    paginater.current = current
    paginater.total = total
    paginater.totalRows = totalRows
    paginater.pageSize = pageSize
    if current - 1 >= 1
      paginater.previous = current - 1
    else
      paginater.previous = 0

    if current + 1 <= total
      paginater.next = current + 1
    else
      paginater.next = 0

    $('.paginater').html JST['app/scripts/templates/paginater.ejs'] paginater

  parseQueryString: (queryString) ->
    params = {}
    queries = queryString.split '&'
    for item in queries
      parts = item.split '='
      if parts[0] in ARRAY_COLUMN
        value = parts[1].split ','
      else
        value = parts[1]
      params[parts[0]] = value
    return params

  truncateString: (input_string, length) ->
    if input_string.length > length
      return input_string.substring(0, length - 3) + '...'
    else
      return input_string

  confirm: (msg, yesFunction, noFunction) ->
    $('#confirm-title').html msg
    dialog = $('#confirm-dialog')

    $('#confirm-yes-btn').click =>
      yesFunction()
      $('.confirm-btn').off('click')

    $('#confirm-no-btn').click =>
      noFunction()
      $('.confirm-btn').off('click')

    do dialog.show
    do dialog.modal

  alert: (msg) ->
    $('#alert-body').html msg
    dialog = $('#alert-dialog')

    do dialog.show
    do dialog.modal

  notify: (msg) ->
    $('#notify-body').html msg
    dialog = $('#notify-dialog')

    do dialog.show
    do dialog.modal

  checkAuthz: (query) ->
    if query?
      parsedQuery = Codeburner.Utilities.parseQueryString(query)
      unless parsedQuery.authz == undefined
        localStorage.setItem "authz", parsedQuery.authz
        Codeburner.Utilities.getRequest "/api/user", ((data) =>
          Codeburner.User = data
          Codeburner.Utilities.authz()
          redirectTo = localStorage.getItem "authRedirect"
          if redirectTo
            localStorage.removeItem "authRedirect"
            window.location.hash = redirectTo
        ), (data) ->
          Codeburner.User = null
          console.log "invalid authz token"

  authz: ->
    if localStorage.getItem "authz"
      Codeburner.Utilities.getRequest "/api/user", ((data) =>
        Codeburner.User = data
        $('#login-menu').html JST['app/scripts/templates/login_menu.ejs']
          name: Codeburner.User.name
          profileUrl: Codeburner.User.profile_url
          avatarUrl: Codeburner.User.avatar_url
        $('#user-signout').on 'click', ->
          localStorage.removeItem "authz"
          window.location = "/"
        $('#user-preferences').on 'click', ->
          window.location ="/#user"
      ), (data) ->
        Codeburner.User = null
        console.log "invalid authz token"
