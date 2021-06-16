# frozen_string_literal: true

port = ENV.fetch('REDIS_PORT', '6380')

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:#{port}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:#{port}" }
end

# For this project log to file
logger = Logger.new File.expand_path('../../log/sidekiq.log', __dir__)
logger.formatter = Ruby::JSONFormatter::Base.new ENV.fetch('HOST', 'no-host')

Sidekiq.logger = logger
Sidekiq.logger.level = Logger::DEBUG
