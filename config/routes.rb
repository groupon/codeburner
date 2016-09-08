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
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"

  namespace :api do
    match 'oauth/callback' => 'oauth#callback', :via => :get
    match 'oauth/authorize' => 'oauth#authorize', :via => :get
    match 'oauth/user' => 'oauth#user', :via => :get

    resources :repo, :only => [:index, :show] do
      member do
        get 'stats'
        get 'branches'
        match 'stats/history' => 'repo#history', :via => :get
        match 'stats/burns' => 'repo#burns', :via => :get
        match 'stats/history/range' => 'repo#history_range', :via => :get
        match 'stats/history/resolution' => 'repo#history_resolution', :via => :get
      end
    end

    resources :filter, :only => [:index, :show, :create, :destroy]

    resources :burn, :only => [:index, :show, :create ] do
      member do
        get 'reignite'
        get 'livelog'
        get 'log'
      end
    end

    resources :finding, :only => [:index, :show, :update] do
      put 'publish', on: :member
    end

    resources :stats, :only => [:index] do
      collection do
        get 'burns'
        match "/history" => "stats#history", :via => :get
        match "/history/range" => "stats#range", :via => :get
        match "/history/resolution" => "stats#resolution", :via => :get
      end
    end

    resources :user, :only => [ :index, :show ] do
      member do
        get 'webhooks'
        match 'repos' => 'user#add_repo_hook', :via => :post
        match 'repos/:repo' => 'user#remove_repo_hook', :via => :delete
      end
    end

    resources :token, :only => [ :index, :show, :create, :destroy ]

    match 'settings' => 'settings#index', :via => :get
    match 'settings' => 'settings#update', :via => :post
    match 'settings/admin' => 'settings#admin_list', :via => :get
    match 'settings/admin' => 'settings#admin_update', :via => :post

    match 'github/search/:type' => 'github#search', :via => :get
    match 'github/branches' => 'github#branches', :via => :get
    match 'github/webhook' => 'github#webhook', :via => :post
  end
end
