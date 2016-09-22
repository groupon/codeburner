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
  'repo_id'
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
        'Authorization': 'JWT ' + localStorage.getItem("authz")
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
        'Authorization': 'JWT ' + localStorage.getItem("authz")
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
        'Authorization': 'JWT ' + localStorage.getItem("authz")
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
        'Authorization': 'JWT ' + localStorage.getItem("authz")
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
      Codeburner.Utilities.getRequest "/api/user", ((data) ->
        Codeburner.User = data

        sync = Backbone.sync
        Backbone.sync = (method, model, options) ->
          options.beforeSend = (xhr) ->
            xhr.setRequestHeader "Authorization", "JWT " + localStorage.getItem "authz"
          sync(method, model, options)

        $('.navbar-hidden').fadeIn(500)
        $('#navbar-settings').fadeIn(500)

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

    return $.Deferred().resolve(false)

  selectRepo: ->
    $('#select-repo').selectize
      valueField: 'full_name'
      labelField: 'full_name'
      searchField: [ 'name', 'html_url', 'full_name' ]
      create: false
      render:
        option: (item, escape) ->
          if item.fork
            repoIcon = 'octicon-repo-forked'
          else
            repoIcon = 'octicon-repo'

          html = '<div>' +
            '<span class="title">' +
              '<span class="name"><span class="octicon ' + repoIcon + '"></span> ' + escape(item.name) + '</span>' +              '<span class="by">' + escape(item.owner.login) + '</span>' +
            '</span>' +
            '<span class="description">' + escape(item.description) + '</span>' +
            '<ul class="meta">' +
              '<li class="language"><span class="octicon octicon-code"></span> ' + escape(item.language) + '</li>' +
              '<li class="stargazers"><span class="octicon octicon-star"></span><span> ' + escape(item.stargazers_count) + '</span> </li>' +
              '<li class="forks"><span class="octicon octicon-repo-forked"></span><span> ' + escape(item.forks) + '</span> </li>' +
            '</ul>' +
          '</div>'

          return html
        item: (item, escape) =>
          if item.fork
            repoIcon = 'octicon-repo-forked'
          else
            repoIcon = 'octicon-repo'

          return "<div><span class='octicon #{repoIcon}'></span>&nbsp;#{item.full_name}</div>"

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

      onChange: (value) ->
        Codeburner.Utilities.renderBranchSelector value

  renderBranchSelector: (repo, selectedRepo, cb) ->
    do $('#branch-div').show
    if $('#select-branch')[0].selectize
      do $('#select-branch')[0].selectize.destroy
    branchSelector = $('#select-branch').selectize
      valueField: 'name'
      labelField: 'name'
      searchField: ['name']
      create: false
      preload: true
      render:
        option: (option, escape) ->
          return "<div><span class='octicon octicon-git-branch'></span>&nbsp;#{option.name}</div>"
        item: (item, escape) ->
          return "<div><span class='octicon octicon-git-branch'></span>&nbsp;#{item.name}</div>"
      load: (query, callback) ->
        Codeburner.Utilities.getRequest "/api/github/branches?repo=#{encodeURIComponent(repo)}", ((data) ->
          callback data
        ), (data) ->
          do callback
      onLoad: (data) ->
        if selectedRepo?
            branchSelector[0].selectize.setValue selectedRepo
        else
          if _.where(data, {name: 'master'}).length > 0
            branchSelector[0].selectize.setValue 'master'
          else
            branchSelector[0].selectize.setValue data[0].name
      onChange: (value) ->
        cb repo, value if cb?
