source 'https://rubygems.org'

# sidekiq
gem 'sidekiq', '>= 3.4.2'
gem 'sinatra', :require => false # for the UI
gem 'slim'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'

# mysql db
gem 'mysql2', '~> 0.3.20', '>= 0.3.20'

# default model attributes
gem 'attribute-defaults'

# pagination
gem 'kaminari'

group :development, :test do
  gem 'capistrano-bundler'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # capistrano for deployment
  gem 'capistrano'
  gem 'capistrano-sidekiq'
  gem 'capistrano-rails'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'minitest-reporters'
  gem 'mocha'
  gem 'simplecov'
  gem 'codeclimate-test-reporter', :require => false
end

# for our global $app_config struct
gem 'deep_struct'

# respond_to
gem 'responders'

# rest-client for general use
gem 'rest-client'

# gems jira and github integration
gem 'jira-ruby'
gem 'octokit'

# scanning stuff
gem 'owasp-pipeline', '>= 0.8.6'
gem 'whenever'
gem 'chronic'

# redis caching
gem 'redis-rails'

# paper_trail for stats generation/tracking
gem 'paper_trail', '>= 4.0.0'

# for OAuth
gem 'jwt'

# for settings
gem 'rails-settings-cached'
