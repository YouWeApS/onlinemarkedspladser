# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

Sidekiq::Logging.logger = Rails.logger

module Sidekiq
  module Middleware
    module Server
      class TaggedLogger
        def call(worker, item, _queue)
          tag = "#{worker.class} #{SecureRandom.hex(12)}"
          ::Rails.logger.tagged(tag) do
            job_info = "Start at #{Time.now.to_default_s}: #{item.inspect}"
            ::Rails.logger.info job_info
            yield
          end
        end
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::TaggedLogger
  end
end

# rubocop:enable Style/ClassAndModuleChildren
