Sidekiq.configure_server do |config|
  config.redis = $redis_options
  Rails.logger = Sidekiq::Logging.logger
end

Sidekiq.configure_client do |config|
  config.redis = $redis_options
end
