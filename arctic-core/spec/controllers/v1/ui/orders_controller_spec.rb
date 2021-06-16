# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::OrdersController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let(:account) { create :account }

  let(:user) { create :user, accounts: [account] }

  let(:shop) { create :shop, account: account }

  let(:vendor) { create :vendor }

  let(:product) { create :product, :matched, shop: shop }

  let!(:config) { create :vendor_shop_configuration, vendor: vendor, shop: shop }

  let!(:order) do
    create :order,
      :with_order_lines,
      shop: shop,
      purchased_at: 1.minute.ago,
      product: product
  end

  let(:params) do
    {
      shop_id: shop.id,
      account_id: account.id,
      vendor_id: vendor.id,
    }
  end

  describe '#show' do
    before { params.merge! id: order.id }

    let(:action) { get :show, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'order:read'

      before { order.update vendor: vendor }

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/order' }
    end
  end

  describe '#statuses' do
    let(:action) { get :statuses, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'order:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/order_statuses' }
    end
  end

  describe '#index' do
    let(:action) { get :index, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'order:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/orders' }

      describe 'filtering on dates' do
        before do
          params.merge! \
            start_date: 3.days.ago,
            end_date: 2.days.ago
        end

        let!(:order2) { create :order, shop: shop, purchased_at: 2.days.ago }
        let!(:order3) { create :order, shop: shop, created_at: 2.days.ago }
        let!(:order4) { create :order, shop: shop, created_at: 4.days.ago }

        it 'returns the orders within the date range' do
          action
          ids = JSON.parse(response.body).collect { |j| j['id'] }
          expect(ids).to match_array [order2.id, order3.id]
        end
      end

      describe 'searching' do
        before do
          params.merge! search: 't&t2'
        end

        let!(:order2) { create :order, shop: shop }
        let!(:order2_line1) { create :order_line, order: order2, track_and_trace_reference: 't&t2' }

        it 'returns the matching orders' do
          action
          ids = JSON.parse(response.body).collect { |j| j['id'] }
          expect(ids).to match_array [order2.id]
        end
      end

      describe 'state' do
        before do
          params.merge! state: :invoiced
        end

        let!(:order2) { create :order, shop: shop }
        let!(:order2_line1) { create :order_line, order: order2, status: :completed }

        let!(:order3) { create :order, shop: shop }
        let!(:order3_line1) { create :order_line, order: order3, status: :invoiced }

        it 'returns the matching orders' do
          action
          ids = JSON.parse(response.body).collect { |j| j['id'] }
          expect(ids).to match_array [order3.id]
        end
      end
    end
  end
end
