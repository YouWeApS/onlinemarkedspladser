# frozen_string_literal: true

class V1::WebhookWorker
  include Sidekiq::Worker

  sidekiq_options \
    queue: :webhooks,
    backtrace: !Rails.env.production?,
    unique: :until_executed

  def perform(vendor_shop_configuration_id, type, *args, **data)
    config = VendorShopConfiguration.find vendor_shop_configuration_id
    V1::Webhook.new(config)
      .public_send(type, *args, **data)
  rescue V1::Webhook::Error => e
    logger.info "Skipping webhook (#{e.class}): #{e.message}"
  end
end
