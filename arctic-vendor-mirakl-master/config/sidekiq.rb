# frozen_string_literal: true

require 'sidekiq_unique_jobs/web'

module Sidekiq::Middleware::Server
  class CanceledCheck
    # @param [Object] worker the worker instance
    # @param [Hash] job the full job payload
    #   * @see https://github.com/mperham/sidekiq/wiki/Job-Format
    # @param [String] queue the name of the queue the job was pulled from
    # @yield the next middleware in the chain or worker `perform` method
    # @return [Void]
    def call(worker, job, queue)
      return if Sidekiq.redis {|c| c.exists("cancelled-#{job['jid']}") }

      yield
    end
  end
end

Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  [username, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
end

redis_port = ENV.fetch('REDIS_PORT', '6381')

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:#{redis_port}" }

  config.death_handlers << ->(job, _ex) do
    SidekiqUniqueJobs::Digests.del(digest: job['unique_digest']) if job['unique_digest']
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:#{redis_port}" }
end

Sidekiq.logger.level = Logger::DEBUG
