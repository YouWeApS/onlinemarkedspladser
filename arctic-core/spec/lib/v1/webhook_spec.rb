require "rails_helper"

RSpec.shared_examples :handle_misconfigured_webhook_url do |hook|
  context 'missing url' do
    before { config.update webhooks: {} }

    it 'does not call the endpoint' do
      expect(Faraday).not_to receive(:post)
      expect { call }.to raise_error \
        V1::Webhook::Error,
        "no webhook configured for #{hook}"
    end
  end

  context 'invalid url' do
    before { config.update webhooks: { hook => 'not-a-url' } }

    it 'does not call the endpoint' do
      expect(Faraday).not_to receive(:post)
      expect { call }.to raise_error \
        V1::Webhook::Error,
        "invalid webhook configured for #{hook}"
    end
  end

  context 'not https url' do
    before do
      config.update webhooks: { hook => 'http://somewhere.com' }
    end

    it 'does not call the endpoint' do
      expect(Faraday).not_to receive(:post)
      expect { call }.to raise_error \
        V1::Webhook::Error,
        "webhook for #{hook} must be an HTTPS url"
    end
  end
end

RSpec.describe V1::Webhook do
  let(:instance) { described_class.new config }
  let(:config) { create :vendor_shop_configuration, :with_webhooks }

  describe '#product_created' do
    let(:call) { instance.product_created 'abcdef123' }
    let(:url) { 'https://somewhere.com/product_created' }

    it 'calls the endpoint' do
      expect(Faraday).to receive(:post).with(url, sku: 'abcdef123')
      call
    end

    it_behaves_like :handle_misconfigured_webhook_url, :product_created
  end

  describe '#product_updated' do
    let(:call) { instance.product_updated 'abcdef123', name: 'New name' }
    let(:url) { 'https://somewhere.com/product_updated' }

    it 'calls the endpoint' do
      expect(Faraday).to receive(:post).with(url, sku: 'abcdef123', name: 'New name')
      call
    end

    it_behaves_like :handle_misconfigured_webhook_url, :product_updated
  end

  describe '#shadow_product_updated' do
    let(:call) { instance.shadow_product_updated 'abcdef123', name: 'New name' }
    let(:url) { 'https://somewhere.com/shadow_product_updated' }

    it 'calls the endpoint' do
      expect(Faraday).to receive(:post).with(url, id: 'abcdef123', name: 'New name')
      call
    end

    it_behaves_like :handle_misconfigured_webhook_url, :shadow_product_updated
  end
end
