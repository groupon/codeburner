#!/bin/env ruby
require 'rubygems'
require 'bundler/capistrano'
require 'capistrano/sidekiq'
require 'whenever/capistrano'

# set sidekiq timeout to 1hr and do NOT restart workers by default
# NOTE: this means you need to do 'cap <env> sidekiq:restart' if anything significant changes in the backend
set :sidekiq_default_hooks, -> { false }

set :whenever_roles, ->{ [:web, :app] }
