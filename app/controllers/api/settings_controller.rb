#``
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
require 'pry'

class Api::SettingsController < ApplicationController
  respond_to :json
  before_filter :authz, only: [:admin_update]
  before_filter :authz_no_fail, only: [:index, :update, :admin_list]
  before_filter :admin_only

  def index
    settings = {}
    Setting.get_all.keys.each {|k| settings[k] = Setting[k]}

    render(:json => settings)
  end

  def update
    results = {}

    params[:settings].each do |setting, value|
      Setting.merge!(setting.to_sym, value)
      results.merge!({setting.to_sym => value})
    end

    render(:json => results)
  end

  def admin_list
    render(:json => User.admin.all, :only => [ :name, :fullname, :profile_url, :avatar_url ])
  end

  def admin_update
    if params[:admins]
      User.admin.update_all(:role => 'user')
      params[:admins].each do |admin|
        if admin.length > 0
          user = User.find_or_create_by(name: admin)
          user.role = 'admin'
          user.save
        end
      end
    end

    render(:json => User.admin.all, :only => [ :name, :fullname, :profile_url, :avatar_url ])
  end

end
