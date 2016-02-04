#!/bin/env ruby

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy'
load 'deploy/assets'

require 'capistrano/sidekiq'
# set sidekiq timeout to 1hr and do NOT restart workers by default
# NOTE: this means you need to do 'cap <env> sidekiq:restart' if anything significant changes in the backend
set :sidekiq_default_hooks, -> { false }

namespace :frontend do
  task :build do
    puts run_locally("cd client && grunt build && cp -r dist/* #{Dir.pwd}/public/")
  end
end

namespace :retire do
  task :install do
    run "if [ `retire -V` ]; then echo RetireJS already installed; else sudo npm install -g retire; fi"
    run "sudo npm update -g retire"
  end
end

namespace :nsp do
  task :install do
    run "if [ `nsp --version` ]; then echo NodeSecurityProject already installed; else sudo npm install -g nsp; fi"
    run "sudo npm update -g nsp"
  end
end

before 'deploy', 'frontend:build'
after 'deploy', 'whenever:update_crontab'
after 'deploy', 'retire:install'
after 'deploy', 'nsp:install'
