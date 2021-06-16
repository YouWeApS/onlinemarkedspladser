require "spec_helper"

RSpec.describe Amazon::Workers::ProductError, type: :worker do
  let(:instance) { described_class.new }
  let(:shop_id) { 'b16efb3f-b976-4266-b8f7-4f17650862ae' }
  let(:sku) { 'abcdef123' }
  let(:perform) { instance.perform shop_id, sku, error }
  let(:core_api) { double }
  let(:error) do
    {
      severity: 'error',
      message: 'My error',
    }
  end

  let(:log_msg) do
    "Unable to report error to Core API (StandardError): hello: {:severity=>\"error\", :message=>\"My error\"}"
  end

  before { allow(instance).to receive(:core_api).and_return core_api }

  it 'sends the error to the Core API' do
    expect(core_api).to receive(:report_error).with(shop_id, sku, error)
    expect(core_api).to receive(:update_product_state).with(shop_id, sku, :failed)
    perform
  end

  it 'handles failing to report errors' do
    expect(core_api).to receive(:report_error)
      .with(shop_id, sku, error)
      .and_raise(StandardError, 'hello')
    expect(Arctic.logger).to receive(:error).with(log_msg)
    perform
  end

  context 'warning severity' do
    before { error[:severity] = 'warning' }

    it 'does not fail the dispersal' do
      expect(core_api).to receive(:report_error).with(shop_id, sku, error)
      expect(core_api).not_to receive(:update_product_state)
      perform
    end
  end
end
