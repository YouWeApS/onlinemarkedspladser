# frozen_string_literal: true

# https://github.com/ianheggie/health_check
HealthCheck.setup do |config|
  config.uri = 'heartbeat'

  config.standard_checks = %w[
    database
    migrations
    redis
    cache
    sidekiq-redis
  ]
end
