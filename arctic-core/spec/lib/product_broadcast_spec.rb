require "rails_helper"

RSpec.describe ProductBroadcast do
  let!(:account) { create :account }
  let!(:user1) { create :user, accounts: [account] }
  let!(:user2) { create :user, accounts: [account] }
  let!(:shop) { create :shop, account: account }
  let!(:product) { create :product, shop: shop }
  let!(:shadow1) { create :shadow_product, product: product }
  let!(:shadow2) { create :shadow_product, product: product }
  let(:instance) { described_class.new(shadow1) }

  subject { instance }

  describe '.broadcast' do
    subject { described_class.broadcast product }

    it 're-broadcasts all shadow products' do
      broadcast_instance = double
      expect(ProductBroadcast).to receive(:new).with(shadow1).and_return broadcast_instance
      expect(ProductBroadcast).to receive(:new).with(shadow2).and_return broadcast_instance
      expect(broadcast_instance).to receive(:broadcast).exactly(2).times
      subject
    end

    context 'not given a product' do
      it 'raises an ArgumentError' do
        expect { described_class.broadcast shadow1 }.to \
          raise_error(ArgumentError, 'you must supply a Product')
      end
    end
  end

  its(:shadow) { is_expected.to eql shadow1 }

  describe '#broadcast' do
    subject { instance.broadcast }

    let(:json) do
      V1::Ui::ProductBlueprint.render_as_hash shadow1, vendor: shadow1.vendor
    end

    it 'broadcasts the shadow product json to all relevant users' do
      expect(ProductsChannel).to receive(:broadcast_to).with(user1.id, json)
      expect(ProductsChannel).to receive(:broadcast_to).with(user2.id, json)
      subject
    end
  end
end
