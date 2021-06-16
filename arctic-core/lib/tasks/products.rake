# frozen_string_literal: true

namespace :products do
  desc 'Clean up any stuck products'
  task cleanup: :environment do
    stale_dispersals = Dispersal.where('updated_at < ?', 51.minutes.ago).with_state(:inprogress)
    Rails.logger.info "Cleaning stale/stuck dispersals: #{stale_dispersals.count}"

    stale_dispersals.find_each do |dispersal|
      dispersal.update state: :pending
      dispersal.product.save # trigger callbacks
    end
  end
end
