require "spec_helper"

RSpec.describe Amazon::Workers::ProductState, type: :worker do
  let(:instance) { described_class.new }
  let(:shop_id) { 'b16efb3f-b976-4266-b8f7-4f17650862ae' }
  let(:sku) { 'abcdef123' }
  let(:state) { :inprogress }
  let(:perform) { instance.perform shop_id, sku, state }
  let(:core_api) { double }

  before { allow(instance).to receive(:core_api).and_return core_api }

  it 'sends the state to the Core API' do
    expect(core_api).to receive(:update_product_state).with(shop_id, sku, state)
    perform
  end
end
