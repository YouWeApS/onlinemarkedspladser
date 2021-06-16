require "rails_helper"

RSpec.describe V1::Vendors::LastSyncedAtBlueprint do
  Timecop.freeze do
    let!(:config) do
      create :vendor_shop_configuration,
        last_synced_at: 1.minute.ago,
        orders_last_synced_at: 2.minutes.ago
    end

    let!(:orders_synced) { config.orders_last_synced_at.httpdate }

    let!(:products_synced) { config.last_synced_at.httpdate }

    describe 'orders view' do
      subject { Hashie::Mash.new described_class.render_as_hash(config, view: :orders) }
      its(:last_synced_at) { is_expected.to eql orders_synced }
    end

    describe 'products view' do
      subject { Hashie::Mash.new described_class.render_as_hash(config, view: :products) }
      its(:last_synced_at) { is_expected.to eql products_synced }
    end
  end
end
