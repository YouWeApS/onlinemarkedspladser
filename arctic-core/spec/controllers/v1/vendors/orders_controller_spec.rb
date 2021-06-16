# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::OrdersController, type: :controller do
  let!(:shop) { create :shop }
  let!(:params) { { shop_id: shop.id } }

  describe '#update' do
    let(:action) { patch :update, params: params }
    let(:order) { create :order, :with_order_lines, shop: shop }

    before do
      params.merge! \
        id: order.id,
        shop_id: shop.id
    end

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

      before do
        params.merge! \
          receipt_id: 'abcdef123'
      end

      it { expect { action }.to change { order.reload.order_receipt_id }.from(nil).to 'abcdef123' }

      it 'is possible to update associated order lines' do
        params.merge! \
          track_and_trace_reference: 'hhhh123'

        expect(order.reload.order_lines.pluck(:track_and_trace_reference).compact.uniq).not_to include 'hhhh123'
        action
        expect(order.reload.order_lines.pluck(:track_and_trace_reference).compact.uniq).to match_array ['hhhh123']
      end
    end
  end

  describe '#index' do
    let(:action) { get :index, params: params }

    let!(:product1) { create :product, shop: shop }

    let!(:product2) { create :product, shop: shop }

    let!(:order1) { create :order, shop: shop }

    let!(:order2) { create :order, shop: shop }

    let!(:order3) { create :order, shop: shop, updated_at: 5.minutes.from_now }

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      before do
        order1.update vendor: vendor
        order2.update vendor: vendor
        order3.update vendor: vendor
      end

      context 'as dispersal vendor' do
        let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

        it { expect(action).to match_response_schema 'vendors/orders' }

        it 'renders all orders' do
          action
          expect(response.body).to eql V1::Vendors::OrderBlueprint.render([order3, order2, order1])
        end

        context 'some orders locked by the vendor' do
          before { create :vendor_lock, target: order1, vendor: vendor }

          it 'renders only unlocked orders' do
            action
            expect(response.body).to eql V1::Vendors::OrderBlueprint.render([order3, order2])
          end

          it 'renders only orders newer than since' do
            params.merge since: 3.minutes.from_now.httpdate
            action
            id = JSON.parse(response.body)[0]['id']
            expect(id).to eql order3.id
          end
        end
      end

      context 'as collection vendor' do
        let!(:config) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor }

        it { expect(action).to match_response_schema 'vendors/orders' }

        context 'some orders locked by the vendor' do
          before { create :vendor_lock, target: order1, vendor: vendor }

          it 'renders only unlocked orders' do
            action
            expect(response.body).to eql V1::Vendors::OrderBlueprint.render([order3, order2])
          end
        end
      end
    end
  end

  describe '#lock' do
    let(:order) { create :order, shop: shop }

    before { params.merge! order_id: order.id }

    let(:action) { post :lock, params: params }

    it_behaves_like :unauthenticated

    context 'authenticated' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

      it { expect { action }.to change { order.vendor_locks.where(vendor: vendor).count }.by(1) }
    end
  end

  describe '#unlock' do
    let(:order) { create :order, shop: shop }

    before { params.merge! order_id: order.id }

    let(:action) { delete :unlock, params: params }

    it_behaves_like :unauthenticated

    context 'authenticated' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }
      let!(:lock) { order.vendor_locks.create! vendor: vendor }

      xit { expect { action }.to change { order.vendor_locks.where(vendor: vendor).count }.by(-1) }
    end
  end

  describe '#last_synced_at' do
    let(:action) { get :last_synced_at, params: params }

    subject { action; JSON.parse response.body }

    it_behaves_like :unauthenticated

    context 'authenticated', :perform_sidekiq do
      include_context :authenticated_vendor

      let!(:config) do
        create :vendor_shop_collection_configuration,
          shop: shop,
          vendor: vendor,
          orders_last_synced_at: 1.minute.ago
      end

      it { is_expected.to eql 'last_synced_at' => config.orders_last_synced_at.httpdate }
    end
  end

  describe '#create' do
    let(:action) { post :create, params: params }

    let(:product1) { create :product, shop: shop }
    let(:product2) { create :product, shop: shop }

    before do
      params.merge! \
        order_id: '202-2004693-3726759',
        shipping_fee: 111,
        payment_fee: 222,
        currency: 'SEK',

        raw_data: {
          a: :b,
          c: {
            d: :e,
          },
        },

        order_lines_attributes: [
          {
            line_id: 1,
            product_id: product1.sku,
            quantity: 2,
            cents_with_vat: 12000,
            cents_without_vat: 10000,
          },
          {
            product_id: product2.sku,
            quantity: 1,
            cents_with_vat: 12000,
            cents_without_vat: 10000,
          },
        ],

        billing_address: {
          name: 'Bob Hansen',
          address1: 'Somweher 1a',
          city: 'Copenhagen',
          country: 'DK',
          zip: 1246,
          phone: '12345678',
          email: 'some@email.com',
        },

        shipping_address: {
          name: 'Bob Hansen',
          address1: 'Somweher 1a',
          city: 'Copenhagen',
          country: 'DK',
          zip: 1246,
          phone: '12345678',
          email: 'some@email.com',
        }
    end

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      context 'as dispersal vendor' do
        let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

        let!(:s1) { create :shadow_product, product: product1, vendor_shop_configuration: config }
        let!(:s2) { create :shadow_product, product: product2, vendor_shop_configuration: config }

        it { expect { action }.to change { shop.orders.count }.by(1) }
        it { expect { action }.to change { Address.count }.by(1) }

        it_behaves_like :http_status, 201

        it 'calculates the correct total' do
          action
          expect(shop.reload.orders.last.total_without_vat).to eql Money.new(20333, 'SEK')
        end

        it 'stores the raw_data' do
          action
          expect(shop.reload.orders.last.raw_data.last.data).to eql({
            'a' => 'b',
            'c' => {
              'd' => 'e',
            },
          })
        end

        it 'saves the order lines' do
          action
          expect(shop.reload.orders.last.order_lines.pluck(:product_id))
            .to match_array [product1.sku, product2.sku]
        end

        it 'uses the defined ID' do
          action
          expect(shop.reload.orders.last.order_id).to eql '202-2004693-3726759'
        end

        context 'failing to save' do
          before do
            expect_any_instance_of(Order).to receive(:save!)
              .and_raise(ActiveRecord::RecordInvalid, Order.new)
          end

          it_behaves_like :http_status, 400

          it 'logs the error' do
            expect(Rails.logger).to receive(:error).with('Translating ActiveRecord::RecordInvalid -> HttpError::BadRequest: Validation failed: ')
            action
          end
        end

        context 'none-existing product' do
          before do
            params[:order_lines_attributes] = [
              {
                line_id: 1,
                product_id: 'uuuuuu',
                quantity: 2,
                cents_with_vat: 12000,
                cents_without_vat: 10000,
              },
            ]
          end

          it 'creates the missing product' do
            expect { action }.to change { Product.unscoped.count }.by(1)
            expect(Product.unscoped.last.sku).to eql 'uuuuuu'
          end

          it 'creates the missing order' do
            expect { action }.to change { Order.count }.by(1)
          end

          it 'creates the missing order line' do
            expect { action }.to change { OrderLine.count }.by(1)
          end
        end
      end

      context 'as collection vendor' do
        let!(:config) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor }

        it { expect { action }.to change { shop.orders.count }.by(1) }
        it { expect { action }.to change { Address.count }.by(1) }

        it_behaves_like :http_status, 201
      end
    end
  end
end
