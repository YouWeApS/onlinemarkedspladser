# frozen_string_literal: true

require 'uri'

# Webhook documentation: http://bit.ly/2CXLfcf
class V1::Webhook
  Error = Class.new StandardError

  attr_reader :config, :options

  def initialize(vendor_shop_configuration, **options)
    @config = vendor_shop_configuration
    @options = options
  end

  # A Product record is created
  def product_created(sku, *)
    Faraday.post url(:product_created), sku: sku
  end

  # A Product record is updated by a vendor
  def product_updated(sku, changes, *)
    Faraday.post url(:product_updated), changes.merge(sku: sku)
  end

  # A ShadowProduct record is updated by a user
  def shadow_product_updated(id, changes, *)
    Faraday.post url(:shadow_product_updated), changes.merge(id: id)
  end

  private

    def url(endpoint)
      config.webhooks.fetch(endpoint.to_s, nil).tap do |str|
        V1::WebhookUrlValidator.validate endpoint, str
      end
    rescue V1::WebhookUrlValidator::Error => e
      raise Error, e.message
    end
end
