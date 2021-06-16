# frozen_string_literal: true

class Amazon::Orders
  include Sidekiq::Worker

  sidekiq_options retry: 3, backtrace: 20

  sidekiq_retry_in { 5.minutes }

  sidekiq_retries_exhausted do |msg, ex|
    Rollbar.error "Amazon feed failed to complete: #{msg}", ex
  end
end
