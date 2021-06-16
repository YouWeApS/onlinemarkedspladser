require 'rails_helper'
RSpec.describe V1::WebhookWorker, type: :worker do
  let(:instance) { described_class.new }
  let(:perform) { instance.perform config.id, :product_created, *args, **data }
  let(:config) { create :vendor_shop_configuration }
  let(:args) { ['abcdef123'] }
  let(:data) { { a: :b } }

  it { is_expected.to be_processed_in :webhooks }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_retryable true }

  it 'calls V1::Webhook class' do
    webhook = double
    expect(V1::Webhook).to receive(:new).with(config).and_return webhook
    expect(webhook).to receive(:product_created).with(*args, data)
    perform
  end
end
