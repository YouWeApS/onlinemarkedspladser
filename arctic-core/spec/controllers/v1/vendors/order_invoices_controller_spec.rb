require 'rails_helper'

RSpec.describe V1::Vendors::OrderInvoicesController, type: :controller do
  it { is_expected.to be_a V1::Vendors::ApplicationController }

  let(:shop) { create :shop }
  let(:order) { create :order, shop: shop }

  let(:params) do
    {
      shop_id: shop.id,
      order_id: order.id,
    }
  end

  describe '#create' do
    let(:action) { post :create, params: params }
    before do
      params.merge! \
        invoice_id: 'Invoice1234',
        order_lines: [1, 2, 3],
        amount: 12.34,
        currency: 'dkk',
        status: :awaiting_payment
    end

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

      it { expect { action }.to change { order.invoices.count }.by(1) }

      it_behaves_like :http_status, 201

      describe 'created invoice' do
        subject { order.invoices.last }

        before { action }

        its(:invoice_id) { is_expected.to eql 'Invoice1234' }
        its(:order_lines) { is_expected.to eql %w[1 2 3] }
        its(:cents) { is_expected.to eql 1234 }
        its(:currency) { is_expected.to eql 'dkk' }
        its(:status) { is_expected.to eql 'awaiting_payment' }
      end
    end
  end
end
