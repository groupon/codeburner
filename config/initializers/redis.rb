case ENV['RAILS_ENV']
when 'production'
  $redis_options = {
    :host => 'localhost',
    :port => 6379
  }
when 'staging'
  $redis_options = {
    :host => 'localhost',
    :port => 6379
  }
else
  $redis_options = {
    :host => 'localhost',
    :port => 6379
  }
end

$redis = Redis.new($redis_options)

module Codeburner
  class Application < Rails::Application
    config.cache_store = :redis_store, $redis_options, { expires_in: 60.minutes }
  end
end
