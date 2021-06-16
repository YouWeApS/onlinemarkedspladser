require 'rails_helper'

RSpec.describe V1::Ui::Tests::WebhooksController, type: :controller do
  it { is_expected.to be_a V1::Ui::Tests::ApplicationController }

  let(:account) { create :account }
  let(:user) { create :user, accounts: [account] }
  let(:shop) { create :shop, account: account }
  let(:vendor) { create :vendor }
  let(:webhook) { 'invalid webhook' }

  let!(:config) do
    create :vendor_shop_configuration, :with_webhooks,
      shop: shop,
      vendor: vendor
  end

  let(:params) do
    {
      account_id: account.id,
      shop_id: shop.id,
      vendor_id: vendor.id,
      webhook: webhook,
    }
  end

  describe '#test' do
    let(:action) { post :test, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated' do
      include_context :authenticated

      context 'incorrect webhook configurations' do
        let(:webhook) { :product_created }
        before { config.update webhooks: {} }
        it_behaves_like :http_status, 400
      end

      context 'product_created webhook' do
        let(:webhook) { :product_created }

        before do
          expect_any_instance_of(V1::Webhook).to \
            receive(:product_created).with('abcdef123')
        end

        it_behaves_like :http_status, 202
      end

      context 'product_updated webhook' do
        let(:webhook) { :product_updated }

        let(:changes) do
          {
            name: ['Old product name', 'New product name'],
          }
        end

        before do
          expect_any_instance_of(V1::Webhook).to \
            receive(:product_updated).with('abcdef123', changes)
        end

        it_behaves_like :http_status, 202
      end

      context 'shadow_product_updated webhook' do
        let(:webhook) { :shadow_product_updated }

        let(:changes) do
          {
            name: ['Old product name', 'New product name'],
          }
        end

        before do
          expect_any_instance_of(V1::Webhook).to \
            receive(:shadow_product_updated).with('abcdef123', changes)
        end

        it_behaves_like :http_status, 202
      end
    end
  end
end
