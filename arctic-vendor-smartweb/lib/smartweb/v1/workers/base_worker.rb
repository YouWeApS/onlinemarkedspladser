# frozen_string_literal: true

class Smartweb::V1::Workers::BaseWorker
  include Sidekiq::Worker

  sidekiq_options \
    backtrace: true,
    unique: :until_executed,
    on_conflict: :log,
    retry: 0

  sidekiq_retries_exhausted do |msg, ex|
    Rollbar.error ex
  end

  def self.cancel! jid
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end
end
