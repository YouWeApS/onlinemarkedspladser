# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::VendorShopConfigurationsController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let!(:account) { create :account }
  let!(:user) { create :user, accounts: [account] }
  let!(:shop) { create :shop, account: account }
  let!(:vendor) { create :vendor }
  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }
  let!(:product1) { create :product, shop: shop }
  let!(:shadow1) { create :shadow_product, vendor_shop_configuration: config, product: product1 }
  let!(:product2) { create :product, shop: shop }
  let!(:shadow2) { create :shadow_product, vendor_shop_configuration: config, product: product2 }

  let(:params) do
    {
      shop_id: shop.id,
      vendor_id: vendor.id,
      account_id: account.id,
    }
  end

  describe '#show' do
    let(:action) { get :show, params: params }

    # it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 200
    end
  end

  describe '#update' do
    let(:action) { patch :update, params: params }

    before do
      params.merge! \
        auth_config: {
          marketplace_id: 'abcdef123',
        },
        config: {
          site_id: 12,
        },
        currency_config: {
          currency: 'EUR',
        },
        enabled: false,
        price_adjustment_value: 15,
        webhooks: {
          a: :b
        }
    end

    # it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 200

      it { expect { action }.to change { config.reload.auth_config['marketplace_id'] }.from(nil).to 'abcdef123' }

      it { expect { action }.to change { config.reload.price_adjustment_value }.from(0.0).to 15.0 }

      it { expect { action }.to change { config.reload.config }.from({}).to 'site_id' => '12' }

      it { expect { action }.to change { config.reload.enabled }.from(true).to false }

      it { expect { action }.to change { config.reload.currency_config }.from('currency' => 'GBP').to 'currency' => 'EUR' }

      it { expect { action }.to change { config.reload.webhooks }.from({}).to 'a' => 'b' }

      xit "clears the cache for all the configured shop's products" do
        expect(Rails.cache).to receive(:delete).with([vendor.id, shadow1.id])
        expect(Rails.cache).to receive(:delete).with([vendor.id, shadow2.id])
        action
      end

      context 'forcing import' do
        before { params.merge! force_import: true }

        it 'clears all *last_synced_at timestamps' do
          config.update \
            last_synced_at: 1.second.ago,
            orders_last_synced_at: 2.seconds.ago

          action

          expect(config.reload.last_synced_at).to be_nil
          expect(config.orders_last_synced_at).to be_nil
        end
      end
    end
  end
end
