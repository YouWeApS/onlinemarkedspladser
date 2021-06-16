# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::ProductErrorsController, type: :controller do
  let(:shop) { create :shop, product_formatter: 'V1::EliteArmorFormatter' }

  let!(:product) { create :product, :with_prices, shop: shop }

  let(:params) do
    {
      shop_id: shop.id,
      product_id: product.sku,
    }
  end

  describe '#create' do
    let(:action) { post :create, params: params }

    it_behaves_like :unauthenticated

    context 'authenticated' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }
      let!(:shadow_product) { create :shadow_product, product: product, vendor_shop_configuration: config }

      it_behaves_like :http_status, 400

      it { expect(action).to match_response_schema 'error' }

      context 'valid error' do
        let(:error_params) do
          {
            message: 'Some error',
            details: 'Error details',
            severity: 'warning',
            raw_data: {
              some: {
                raw: :json,
              },
            },
          }
        end

        before do
          params.merge! error_params
        end

        it 'updates the product cache' do
          expect(ProductCache).to receive(:write).with(product)
          action
        end

        it { expect { action }.to change {
          shadow_product.reload.product_errors.count }.from(0).to(1) }

        it_behaves_like :http_status, 200

        describe 'failing dispersals' do
          it 'leaves the dispersal as inprogress' do
            dispersal = create :dispersal, product: product, vendor_shop_configuration: config, state: :inprogress
            expect { action }.not_to change { dispersal.reload.state }
          end

          context 'error severity' do
            before { params[:severity] = :error }

            it 'fails the dispersal' do
              dispersal = create :dispersal, product: product, vendor_shop_configuration: config, state: :inprogress
              expect { action }.to change { dispersal.reload.state }.from('inprogress').to('failed')
            end
          end
        end

        context 'resubmitting error' do
          let!(:existing_error) { create :product_error, error_params.merge(shadow_product: shadow_product) }

          it "doesn't create dublicates" do
            expect { action }.to change { ProductError.count }.by(0)
          end
        end

        describe 'created error' do
          subject do
            action
            ProductError.last
          end

          its(:message) { is_expected.to eql 'Some error' }
          its(:details) { is_expected.to eql 'Error details' }
          its(:severity) { is_expected.to eql 'warning' }
          its(:raw_data) { is_expected.to eql 'some' => { 'raw' => 'json' } }
        end

        context 'invalid severity' do
          before { params[:severity] = 'helllo' }

          it_behaves_like :http_status, 400

          it { expect(action).to match_response_schema 'error' }
        end
      end
    end
  end
end
