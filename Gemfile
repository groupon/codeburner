# sidekiq
gem 'sidekiq', '>= 3.4.2'
gem 'sinatra', :require => false # for the UI
gem 'slim'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'

# mysql db
gem 'mysql2', '~> 0.3.20', '>= 0.3.20'

# bundle exec rake doc:rails generates the API under doc/api.
group :doc do
  gem 'sdoc', '~> 0.4.0'
end

# default model attributes
gem 'attribute-defaults'

# pagination
gem 'kaminari'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # capistrano for deployment
  gem 'capistrano-sidekiq'
  gem 'capistrano-rails'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'minitest-reporters'
  gem 'mocha'
  gem 'simplecov'
end

# for our global $app_config struct
gem 'deepstruct'

# rack server
gem 'unicorn', '~> 4.9.0', '>= 4.9.0'

# rest-client for general use
gem 'rest-client'

# gems jira and github integration
gem 'jira-ruby'
gem 'octokit'

# scanning stuff
gem 'pipeline', '>= 0.8.2'
gem 'brakeman', '>= 3.1.0'
gem 'bundler-audit', '>= 0.4.0'
gem 'whenever'
gem 'chronic'

# redis caching
gem 'redis-rails'

# paper_trail for stats generation/tracking
gem 'paper_trail', '>= 4.0.0'
