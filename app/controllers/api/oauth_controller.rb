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
    csrf_token = JWT.encode({:client_id => Setting.github['oauth']['client_id'], :exp => 1.minute.from_now.to_i }, Rails.application.secrets.secret_key_base)
    authorize_url = "#{Setting.github['link_host']}/login/oauth/authorize?client_id=#{Setting.github['oauth']['client_id']}&scope=#{Setting.github['oauth']['scope']}&state=#{csrf_token}"

    redirect_to authorize_url
  end

  def user
    render(:json => @current_user, :only => [ :name, :fullname, :profile_url, :avatar_url ])
  end

  def callback
    begin
      unless params.has_key?(:code) and params.has_key?(:state) and JWT.decode(params[:state], Rails.application.secrets.secret_key_base)[0]['client_id'] == Setting.github['oauth']['client_id']
        return render(:json => {error: 'Unauthorized'}, :status => :forbidden)
      end

    rescue JWT::DecodeError
      return render(:json => {error: 'Invalid CSRF token in OAuth callback'}, :status => :forbidden)
    end

    token_url = "#{Setting.github['link_host']}/login/oauth/access_token"
    payload = {
      :client_id => Setting.github['oauth']['client_id'],
      :client_secret => Setting.github['oauth']['client_secret'],
      :code => params[:code]
    }

    response = JSON.parse(RestClient.post(token_url, payload, {:Accept => 'application/json'}))

    if response.has_key? 'access_token'
      Octokit.configure do |c|
        if Setting.github['api_endpoint']
          c.api_endpoint = Setting.github['api_endpoint']
        end
      end
      user_github = Octokit::Client.new(:access_token => response['access_token'])
      user_info = user_github.user

      user = User.find_or_create_by(:github_uid => user_info[:id]) do |u|
        u.name = user_info[:login]
        u.fullname = user_info[:name]
        u.profile_url = user_info[:html_url]
        u.avatar_url = user_info[:avatar_url]
        u.access_token = response['access_token']
      end

      jwt = JWT.encode({:uid => user.github_uid, :exp => 6.hours.from_now.to_i}, Rails.application.secrets.secret_key_base)

      authenticated_url = "#{Setting.email['link_host']}#?authz=#{jwt}"

      redirect_to authenticated_url
    else
      return render(:json => {error: 'GitHub Authorization Failed'}, :status => :forbidden)
    end
  end

end
