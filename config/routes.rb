require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"

  namespace :api do
    resources :service, :only => [:index, :show] do
      member do
        get 'stats'
        match 'stats/history' => 'service#history', :via => :get
        match 'stats/burns' => 'service#burns', :via => :get
        match 'stats/history/range' => 'service#history_range', :via => :get
        match 'stats/history/resolution' => 'service#history_resolution', :via => :get
      end
    end

    resources :filter, :only => [:index, :show, :create, :destroy]
    resources :burn, :only => [:index, :show, :create]

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
  end
end
