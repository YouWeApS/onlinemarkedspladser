# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::ProductCacheWorker, type: :worker do
  it { is_expected.to be_processed_in :product_caches }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_retryable true }

  let!(:product1) { create :product, master: master }
  let!(:product2) { create :product, master: master }
  let!(:master) { create :product }

  let(:instance) { described_class.new }
  let(:perform) { instance.perform(product_id) }

  context 'when given master product' do
    let(:product_id) { master.sku }

    it 'clears all product caches' do
      expect(ProductCache).to receive(:write).with(product1)
      expect(ProductCache).to receive(:write).with(product2)
      expect(ProductCache).to receive(:write).with(master)
      perform
    end
  end

  context 'when given variant product' do
    let(:product_id) { product1.sku }

    it 'requeues the master product' do
      expect(described_class).to receive(:perform_async).with(product1.master_sku)
      perform
    end
  end

  context 'invalid product SKU' do
    let(:product_id) { 'hello' }

    it "doesn't raise exception" do
      expect { perform }.not_to raise_error
    end

    it 'logs the event' do
      msg = /Unable to clear cache for Product\(hello\)/
      expect(Sidekiq.logger).to receive(:error).with msg
      perform
    end
  end
end
