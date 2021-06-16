# frozen_string_literal: true

class V1::Ui::Tests::WebhooksController < V1::Ui::Tests::ApplicationController
  attr_reader :webhook

  WEBHOOKS = %w[
    product_created
    product_updated
    shadow_product_updated
  ].freeze

  rescue_from V1::Webhook::Error do |e|
    logger.error "Translating #{e.class} -> HttpError::BadRequest: #{e.message}"
    error = HttpError::BadRequest.new e.message
    render_error error
  end

  def test
    @webhook = V1::Webhook.new current_vendor_config
    desired_webhook = (WEBHOOKS & [params[:webhook]]).first
    public_send "test_#{desired_webhook}"
    head :accepted
  end

  def test_product_created
    product = FactoryBot.build :product, sku: 'abcdef123'
    webhook.product_created product.sku
  end

  def test_product_updated
    product = FactoryBot.build :product, sku: 'abcdef123'
    webhook.product_updated product.sku,
      name: ['Old product name', 'New product name']
  end

  def test_shadow_product_updated
    product = FactoryBot.build :product, sku: 'abcdef123'
    webhook.shadow_product_updated product.sku,
      name: ['Old product name', 'New product name']
  end
end
