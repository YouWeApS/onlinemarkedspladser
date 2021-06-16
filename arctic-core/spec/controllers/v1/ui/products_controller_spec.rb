
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::ProductsController, type: :controller do
  let(:account) { create :account }
  let!(:user) { create :user, accounts: [account] }
  let(:shop) { create :shop, account: account }
  let(:vendor) { create :vendor }
  let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

  let(:master_product) { create :product, shop: shop, sku: 'aaaa' }
  let!(:shadow_master_product) { create :shadow_product, product: master_product, vendor_shop_configuration: config, enabled: true }

  let(:product) { create :product, :with_prices, shop: shop, master: master_product, sku: 'BBB-1', ean: '4025258722340' }
  let!(:shadow_product) { create :shadow_product, product: product, vendor_shop_configuration: config, sku: 'BBB-2', enabled: true }

  let(:other_product) { create :product, :with_prices, shop: shop, master: master_product, sku: 'BBB-3' }
  let!(:deleted_shadow_product) { create :shadow_product, product: other_product, vendor_shop_configuration: config, enabled: true }
  before { deleted_shadow_product.destroy }

  let(:params) do
    {
      account_id: account.id,
      shop_id: shop.id,
      vendor_id: vendor.id,
    }
  end

  describe '#raw' do
    before do
      params.merge! \
        id: shadow_product.id
    end

    let!(:raw_product_data) do
      create :raw_product_data,
        product: product,
        data: {
          name: 'Product A',
          color: 'Color: Black',
          manufacturers: [
            {
              name: 'Unicorns Inc.',
            },
          ],
        }
    end

    let(:action) { get :raw, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'
      it_behaves_like :http_status, 200
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
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/product_list_item' }

      it 'does not include deleted products' do
        action
        skus = JSON.parse(response.body).collect { |pr| pr['sku'] }
        expect(skus).not_to include deleted_shadow_product.product_id
      end

      describe 'searching' do
        before { params.merge! search: 'aaa' }

        it 'returns the matching products' do
          action
          skus = JSON.parse(response.body).collect { |pr| pr['sku'] }
          expect(skus).to match_array [master_product.sku]
        end
      end

      describe 'including deleted' do
        before { params.merge! removed: true }

        it 'includes deleted products' do
          action
          skus = JSON.parse(response.body).collect { |pr| pr['sku'] }
          expect(skus).to include deleted_shadow_product.product_id
        end
      end

      describe 'including all' do
        before { params.merge! removed: false }

        it 'includes all products' do
          action
          skus = JSON.parse(response.body).collect { |pr| pr['sku'] }
          expect(skus).to match_array [shadow_product.sku,
                                       shadow_master_product.product_id,
                                       deleted_shadow_product.product_id]
        end
      end

      describe 'only masters' do
        before { params.merge! master: true }

        it 'includes only master products' do
          action
          skus = JSON.parse(response.body).collect { |pr| pr['sku'] }
          expect(skus).to match_array [master_product.sku]
        end
      end

      describe 'filtering products' do
        let(:erroneous_product) { create :product, :with_prices, shop: shop, master: master_product, sku: 'ERROR-1',
                                         ean: '6666666666666' }
        let!(:shadow_erroneous_product) { create :shadow_product, product: erroneous_product,
                                                 vendor_shop_configuration: config}
        context 'erroneous' do
          before do
            create :vendor_product_match, product: master_product, matched: true, vendor_shop_configuration: config
            create :vendor_product_match, product: product, matched: true, vendor_shop_configuration: config
            create :product_error, severity: 'error', shadow_product: shadow_erroneous_product
            params.merge! state: 'erroneous'
          end

          it 'returns only the erroneous products' do
            action

            blueprint = V1::Ui::ProductListBlueprint.render([
                                                            shadow_erroneous_product
                                                        ], vendor: vendor)

            expect(JSON.parse(response.body)[0]['id']).to eql JSON.parse(blueprint)[0]['id']
          end
        end

        context 'unmatched' do
          before do
            create :vendor_product_match, product: master_product, matched: false, vendor_shop_configuration: config
            create :vendor_product_match, product: product, matched: true, vendor_shop_configuration: config
            params.merge! state: 'erroneous'
          end

          it 'returns only the unmatched products' do
            action

            blueprint = V1::Ui::ProductListBlueprint.render([
                                                            shadow_master_product
                                                        ], vendor: vendor)

            expect(JSON.parse(response.body)[0]['id']).to eql JSON.parse(blueprint)[0]['id']
          end
        end

        context 'dispersed' do
          before do
            create :dispersal, product: product, state: :completed
            params.merge! state: 'dispersed'
          end

          it 'returns only the dispersed products' do
            action

            blueprint = V1::Ui::ProductListBlueprint.render([
                                                            shadow_product
                                                        ], vendor: vendor)

            expect(JSON.parse(response.body)[0]['id']).to eql JSON.parse(blueprint)[0]['id']
          end
        end
      end
    end
  end

  describe '#destroy' do
    let(:action) { delete :destroy, params: params }
    before { params.merge! id: shadow_product.id }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 204

      it { expect { action }.to change { ShadowProduct.count }.by(-1) }

      it 'updates the product cache' do
        expect(ProductCache).to receive(:write).with shadow_product
        action
      end
    end
  end

  describe '#update' do
    let(:action) { patch :update, params: params }

    before do
      params.merge! \
        id: shadow_product.id,
        name: 'New product name',
        categories: %w[t y],
        sync: true,
        platinum_keywords: {
          '1': 'test'
        },
        key_features: {
            '2': 'test1'
        },
        offer_price: {
          cents: 10200,
          currency: 'GBP',
        },
        search_terms: 'search_terms',
        legal_disclaimer: 'legal_disclaimer'
    end

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/product' }

      it { expect { action }.to change { shadow_product.reload.name }.from(nil).to('New product name') }

      it { expect { action }.to change { shadow_product.reload.categories }.from([]).to(%w[t y]) }

      it { expect { action }.to change { shadow_product.reload.product.updated_at } }

      it { expect { action }.to change { shadow_product.reload.offer_price.try :price }.to(Money.new(10200, 'GBP')) }

      it { expect { action }.to change { shadow_product.reload.platinum_keywords }.to({"1" => "test"}) }

      it { expect { action }.to change { shadow_product.reload.key_features }.to({"1" => "test1"}) }

      it { expect { action }.to change { shadow_product.reload.search_terms }.to('search_terms') }

      it { expect { action }.to change { shadow_product.reload.legal_disclaimer }.to('legal_disclaimer') }

      it { expect { action }.to change { shadow_product.reload.product.update_scheduled }.from(false).to(true) }

      it 'recalculates vendor matches' do
        expect(V1::Vendors::ChannelProductMatchWorker).to receive(:perform_async)
          .with(shadow_product.product.shop_id, shadow_product.product_id)
        action
      end

      it 'calls the webhook worker' do
        expect(V1::WebhookWorker).to receive(:perform_async)
        action
      end

      it 'updates the product cache for all children and it self' do
        expect(ProductCache).to receive(:write).with shadow_product
        expect(V1::Ui::ProductCacheWorker).to receive(:perform_async).with(product.sku)
        action
      end

      describe 'setting dispersal state' do
        context 'no product errors' do
          it 'is set to pending' do
            dispersal = create :dispersal, product: product, vendor_shop_configuration: config, state: :failed
            expect { action }.to change { dispersal.reload.state }.from('failed').to 'pending'
          end
        end

        context 'has product errors' do
          it 'leaves the dispersal state' do
            dispersal = create :dispersal, product: product, vendor_shop_configuration: config, state: :failed
            create :product_error, shadow_product: shadow_product
            expect { action }.not_to change { dispersal.reload.state }
          end
        end
      end

      Product::CHARACTERISTICS.each do |f|
        describe "updating #{f}" do
          let!(:old_value) { shadow_product.reload.public_send(f) }
          let(:new_value) { old_value.to_s.number? ? 100 : 'new value' }
          before { params.merge! f => new_value }
          it { expect { action }.to change { shadow_product.reload.public_send(f) }.from(old_value).to(new_value) }
        end
      end

      describe 'update enabled value' do
        before { params[:id] = shadow_master_product.id }
        before { params.merge! enabled: false }
        context 'change enabled' do
           it { expect { action }.to change { shadow_product.reload.enabled }.from(true).to(false) }
        end
      end
    end
  end

  describe '#import' do
    let(:action) { put :import, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 202

      let(:path) { Rails.root.join('tmp' , 'products.csv').to_s }
      let(:file) { fixture_file_upload(path, 'text/csv') }

      before do
        CSV.open(path, "wb") do |csv|
          csv << %w[sku name]
          csv << [product.sku, 'Hello']
        end

        params.merge! file: file
      end

      it 'enqueues the file import' do
        expect(V1::Ui::ProductImportWorker).to receive(:perform_async)
        action
      end
    end
  end

  describe '#export' do
    let(:action) { get :export, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 202

      it 'enqueues the file export' do
        expect(V1::Ui::ProductExportWorker).to receive(:perform_async).with(user.id, vendor.id, shop.id)
        action
      end
    end
  end

  describe '#show' do
    let(:action) { get :show, params: params }

    before do
      params.merge! id: shadow_product.id
    end

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/product' }

      context 'deleted shadow_product' do
        before { shadow_product.destroy }

        it_behaves_like :http_status, 200

        it { expect(action).to match_response_schema 'ui/product' }
      end
    end
  end
end
