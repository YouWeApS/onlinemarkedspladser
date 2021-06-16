# frozen_string_literal: true

class Mirakl::Workers::Base
  include Sidekiq::Worker

  sidekiq_options \
    backtrace: true,
    unique: :until_executed,
    on_conflict: :log,
    retry: 0

  attr_reader :shop_id

  def self.cancel! jid
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end

  private

  def shop
      @shop ||= core_api.get_shop(shop_id)
  end

  def core_api
    @core_api ||= Arctic::Vendor::Dispersal::API.new
  end

  def mirakl_api
    @mirakl_api ||= Mirakl::Api.new shop
  end
end
