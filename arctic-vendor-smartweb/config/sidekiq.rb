# frozen_string_literal: true

require 'sidekiq_unique_jobs/web'
require './lib/sidekiq/middleware/server/canceled_check'

Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  [username, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
end

redis_port = ENV.fetch('REDIS_PORT', '6380')

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:#{redis_port}" }

  config.death_handlers << ->(job, _ex) do
    SidekiqUniqueJobs::Digests.delete_by_digest(job['unique_digest']) if job['unique_digest']
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::CanceledCheck
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:#{redis_port}" }
end

Sidekiq.logger.level = Logger::DEBUG
