require 'rails_helper'

RSpec.describe V1::Vendors::OrderLinesController, type: :controller do
  it { is_expected.to be_a V1::Vendors::ApplicationController }

  let(:shop) { create :shop }
  let(:order) { create :order, shop: shop }
  let(:product) { create :product, shop: shop, sku: 'abcdef123' }

  let(:params) do
    {
      shop_id: shop.id,
      order_id: order.id,
    }
  end

  describe '#statuses' do
    let(:action) { get :statuses, params: params }

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

      it 'renders possible order line statuses' do
        action
        expect(JSON.parse(response.body)).to match_array %w[completed created invoiced shipped]
      end
    end
  end

  describe '#update' do
    let(:action) { patch :update, params: params }
    let!(:order_line) { create :order_line, order: order }

    before do
      params.merge! \
        id: order_line.id,
        track_and_trace_reference: 'abcdef123',
        status: :shipped
    end

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

      it { expect { action }.to change { order_line.reload.track_and_trace_reference }.to 'abcdef123' }
      it { expect { action }.to change { order_line.reload.status }.from('created').to('shipped') }
    end
  end

  describe '#create' do
    let(:action) { post :create, params: params }

    before do
      params.merge! \
        line_id: 1,
        status: 'created',
        product_id: product.id,
        quantity: 3,
        track_and_trace_reference: '2:1234',
        cents_with_vat: 100
    end

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

      it { expect { action }.to change { order.order_lines.count }.by(1) }

      it_behaves_like :http_status, 201

      describe 'created order line' do
        subject { order.order_lines.last }

        before { action }

        its(:line_id) { is_expected.to eql '1' }
        its(:status) { is_expected.to eql 'created' }
        its(:product) { is_expected.to eql product }
        its(:quantity) { is_expected.to eql 3 }
        its(:track_and_trace_reference) { is_expected.to eql '2:1234' }
      end
    end
  end
end
