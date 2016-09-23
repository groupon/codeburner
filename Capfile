# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
# require 'capistrano/passenger'

require 'capistrano/sidekiq'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

namespace :loadbalancer do
  desc "Add app to loadbalancer pool"
  task :add do
    on roles(:app, :web) do
      within release_path do
        execute :echo, "'GRPN' > heartbeat.txt"
      end
    end
  end

  desc "Remove app from loadbalancer pool"
  task :remove do
    on roles(:app, :web) do
      # within makes first deploy to fail
      if test("[ -d #{release_path} ]")
        execute :rm, "-f #{release_path}/heartbeat.txt"
        delay = 5
        if delay > 0
          info "Sleeping #{delay} seconds to allow requests to complete..."
          sleep(delay)
        end
      end
    end
  end
end

namespace :puma do
  %w(start stop status restart).each do |command|
    desc "#{command} puma"
    task command do
      on roles(:app) do
        with gem_home: fetch(:target_gem_home) do
          within "/usr/local/etc/init.d" do
            execute :sudo, "./puma-#{fetch(:application)}", command
          end
        end
      end
    end
  end
end

namespace :logdir do
  desc "create burn logs directory"
  task :create do
    on roles(:app) do
      within release_path do
        execute :mkdir, "log/burns"
      end
    end
  end
end

namespace :frontend do
  desc "build frontend javascript client"
  task :build do
    sh "cd client && grunt build && cp -r dist/* \"#{Dir.pwd}/public/\""
  end
end

namespace :retire do
  desc "install/update retire.js"
  task :install do
    on roles(:app) do
      unless test("[ `retire -V` ]")
        execute :sudo, "npm", "install", "-g", "retire"
      else
        puts "RetireJS already installed"
        execute :sudo, "npm", "update", "-g", "retire"
      end
    end
  end
end

namespace :nsp do
  desc "install/update nsp"
  task :install do
    on roles(:app) do
      unless test("[ `nsp --version` ]")
        execute :sudo, "npm", "install", "-g", "nsp"
      else
        puts "NSP already installed"
        execute :sudo, "npm", "update", "-g", "nsp"
      end
    end
  end
end

namespace :snyk do
  desc "install/update snyk"
  task :install do
    on roles(:app) do
      unless test("[ `snyk --version` ]")
        execute :sudo, "npm", "install", "-g", "snyk"
      else
        puts "snyk already installed"
        execute :sudo, "npm", "update", "-g", "snyk"
      end
    end
  end
end

#before "deploy", 'frontend:build'
before "deploy", 'loadbalancer:remove'
after 'deploy', 'loadbalancer:add'
after 'deploy', 'puma:restart'
after 'deploy', 'logdir:create'
after 'deploy', 'retire:install'
after 'deploy', 'nsp:install'
after 'deploy', 'snyk:install'
