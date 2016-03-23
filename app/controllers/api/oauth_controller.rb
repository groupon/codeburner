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
class Api::OauthController < ApplicationController
  protect_from_forgery

  before_filter :authz, only: [ :user ]

  def authorize
    authorize_url = "#{$app_config.github.link_host}/login/oauth/authorize?client_id=#{$app_config.github.oauth_client_id}&scope=#{$app_config.github.oauth_scope}"

    redirect_to authorize_url
  end

  def user
    render(:json => @current_user, :only => [ :name, :profile_url, :avatar_url ])
  end

  def callback
    return render(:json => {error: 'Unauthorized'}, :status => :forbidden) unless params.has_key?(:code)

    token_url = "#{$app_config.github.link_host}/login/oauth/access_token"
    payload = {
      :client_id => $app_config.github.oauth_client_id,
      :client_secret => $app_config.github.oauth_client_secret,
      :code => params[:code]
    }

    response = JSON.parse RestClient.post(token_url, payload, {:Accept => 'application/json'})

    if response.has_key? 'access_token'
      user_github = Octokit::Client.new(:access_token => response['access_token'])
      user_info = user_github.user

      user = User.find_or_create_by(:github_uid => user_info[:id]) do |u|
        u.name = user_info[:login]
        u.profile_url = user_info[:html_url]
        u.avatar_url = user_info[:avatar_url]
      end

      user.update(:access_token => response['access_token'])

      jwt = JWT.encode({uid: user.github_uid, exp: 6.hours.from_now.to_i}, Rails.application.secrets.secret_key_base)

      authenticated_url = "//#{$app_config.mail.link_host[Rails.env.to_sym]}#?authz=#{jwt}"

      redirect_to authenticated_url
    else
      return render(:json => {error: 'GitHub Authorization Failed'}, :status => :forbidden)
    end
  end

end
