# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::ProductsController,
  type: :controller,
  vcr: :product_validator do

  let(:shop) { create :shop, product_formatter: 'V1::EliteArmorFormatter' }

  let!(:dispersal_vendor) do
    create :vendor,
      id: 'ac2d3139-100a-4011-8ca0-2670fd2ec35b',
      token: '64cf21de-db7a-4370-982a-0d5f14d90c61'
  end

  let!(:product1) { create :product, :with_prices, shop: shop }
  let!(:product2) { create :product, :with_prices, shop: shop }
  let!(:product3) { create :product, :with_prices, shop: shop }
  let!(:product4) { create :product, :with_prices, shop: shop }
  let!(:product5) { create :product, :with_prices, shop: shop }

  let(:params) do
    {
      shop_id: shop.id,
    }
  end

  describe '#last_synced_at' do
    let(:action) { get :last_synced_at, params: params }

    subject { action; JSON.parse response.body }

    it_behaves_like :unauthenticated

    context 'authenticated', :perform_sidekiq do
      include_context :authenticated_vendor

      let!(:config) do
        create :vendor_shop_dispersal_configuration,
          shop: shop,
          vendor: vendor,
          last_synced_at: 1.minute.ago
      end

      it { is_expected.to eql 'last_synced_at' => config.last_synced_at.httpdate }
    end
  end

  describe '#create' do
    let(:action) { post :create, params: params }

    before do
      params.merge! \
        sku: 'Product SKU',
        name: 'Product name',
        material: 'Twaron',
        images: %w[
          https://google.com/1
        ],
        offer_price: {
          cents: 10000,
          currency: 'GBP',
        },
        original_price: {
          cents: 20000,
          currency: 'SEK',
        },
        raw_data: {
          NAME: 'PRODUCT A',
        },
        stock_count: 101
    end

    let(:new_product) { Product.where(shop: shop).find 'Product+SKU' }

    it_behaves_like :unauthenticated

    context 'authenticated', :perform_sidekiq do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor }
      let!(:dispersal_config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: dispersal_vendor }

      it_behaves_like :http_status, 201

      it { expect(action).to match_response_schema 'vendors/product' }

      it { expect { action }.to change { shop.products.count }.by(1) }

      it { expect { action }.to change { dispersal_vendor.reload.vendor_product_matches.count }.by(1) }

      it 'updates the material' do
        action
        expect(shop.products.find('Product+SKU').material).to eql 'Twaron'
      end

      it 'updates the stock count' do
        action
        expect(shop.products.find('Product+SKU').stock_count).to eql 101
      end

      it 'creates a shadow product for each of the vendors' do
        skip "This spec is order-dependant. It fails on seed 6677, but passes on seed 13285" if ENV['CI']
        expect { action }.to change { Product.last.shadow_products.count }.by(1)
      end

      it 'truncates the characteristics to 256 characters' do
        params[:sku] = '1' * 300
        action
        expect { Product.find('1' * 256) }.not_to raise_error
      end

      it 'truncates the product description to 2000 characters' do
        params[:description] = '1' * 2001
        action
        expect(Product.find('Product+SKU').description.length).to eql 2000
      end

      it 'attaches the images' do
        expect { action }.to change { Product.last.images.count }.from(0).to(1)
      end

      it 'calls the product channel match worker' do
        expect(V1::Vendors::ChannelProductMatchWorker).to receive(:perform_async)
          .with(shop.id, 'Product+SKU')
          .at_least(1).times
        action
      end

      it 'calls the shadow product match worker' do
        expect(V1::Vendors::ShadowProductWorker).to \
          receive(:perform_async).with('Product+SKU')
        action
      end

      it 'calls the webhook worker' do
        expect(V1::WebhookWorker).to receive(:perform_async)
          .with(config.id, :product_created, 'Product+SKU')
        action
      end

      describe 'adding prices' do
        it 'creates the product price records' do
          expect { action }.to change { ProductPrice.count }.by(2)
        end

        it 'add the offer_price' do
          action
          expect(new_product.offer_price.price.cents).to eql 10000
          expect(new_product.offer_price.price.currency.iso_code).to eql 'GBP'
        end

        it 'add the original_price' do
          action
          expect(new_product.original_price.price.cents).to eql 20000
          expect(new_product.original_price.price.currency.iso_code).to eql 'SEK'
        end
      end

      context "product isn't valid", vcr: :product_validator_missing_category do
        it { expect { action }.to change { shop.products.count }.by(1) }

        it { expect { action }.to change { dispersal_vendor.reload.vendor_product_matches.unmatched.count }.by(1) }

        it 'logs the match error' do
          action
          matched = dispersal_vendor.reload.vendor_product_matches.unmatched.last
          expect(matched.error.to_sentence).to eql("error: undefined method `classify' for :missing_category_type:Symbol\nDid you mean?  class")
          expect(matched.matched).to be_falsey
        end
      end

      context 'product with master sku' do
        before { params[:master_sku] = product1.sku }

        it "updates the master's vaiants counter cache" do
          expect { action }.to change { product1.reload.variants_count }.by(1)
        end
      end

      context 'existing product' do
        before { params[:sku] = product1.sku }

        it { expect { action }.to change { product1.reload.name }.from(product1.name).to('Product name') }

        it 'calls the webhook worker' do
          Timecop.freeze do
            expect(V1::WebhookWorker).to receive(:perform_async)
            action
          end
        end

        it 'does not store duplicate raw_data' do
          product1.raw_product_data.create! data: {
            NAME: 'PRODUCT A',
          }
          expect { action }.not_to change { product1.reload.raw_product_data.count }.from(1)
        end

        context 'master_sku present' do
          before { params[:master_sku] = product2.sku }

          it 'stores the master sku' do
            expect { action }.to change { product1.reload.master_sku }.from(nil).to product2.sku
          end
        end

        context 'removing product' do
          before { params[:remove] = true }

          it 'soft-deletes the product' do
            expect(product1.deleted_at).to be_nil
            action
            expect(product1.reload.deleted_at).to be_within(1.second).of(Time.zone.now)
          end

          describe 'removing already removed prduct' do
            it 'stays soft-deleted' do
              expect(product1.deleted_at).to be_nil
              action
              expect(product1.reload.deleted_at).to be_within(1.second).of(Time.zone.now)
              action
              expect(product1.reload.deleted_at).to be_within(1.second).of(Time.zone.now)
            end
          end
        end

        context 'restoring product' do
          before { product1.destroy }

          it 'restores the product' do
            expect(product1.reload.deleted_at).to be_within(1.second).of(Time.zone.now)
            action
            expect(product1.reload.deleted_at).to be_nil
          end
        end
      end
    end
  end

  describe '#update' do
    let(:action) { patch :update, params: params }

    before { params[:id] = product1.id }

    it_behaves_like :unauthenticated

    context 'authenticated' do
      include_context :authenticated_vendor

      before do
        params[:state] = :inprogress
      end

      let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

      it_behaves_like :http_status, 200

      it "leaves the product's last_dispersed_at_for blank", :freeze do
        action
        expect(product1.reload.last_dispersed_at_for(vendor)).to be_nil
      end

      it 'updates the dispersal state' do
        action
        expect(product1.reload.dispersals.last.state).to eql 'inprogress'
      end

      it { expect(action).to match_response_schema 'vendors/product' }

      it 'updates the product cache' do
        expect(ProductCache).to receive(:write).with(product1)
        action
      end

      context 'completes dispersal' do
        before { params[:state] = :completed }

        it 'updates the product dispersed_at', :freeze do
          action
          expect(product1.reload.last_dispersed_at_for(vendor)).to \
            be_within(1.second).of(Time.zone.now)
        end
      end

      context 'has previos, completed dispersal' do
        let!(:dispersal) do
          create :dispersal, :completed,
            product: product1,
            vendor_shop_configuration: config
        end

        it 'updates the product dispersed_at', :freeze do
          Timecop.freeze 1.minute.from_now do
            action
            expect(product1.reload.most_recent_dispersal(vendor)).not_to eql(dispersal)
            expect(product1.reload.most_recent_dispersal(vendor)).to be_present
          end
        end

        it 'creates a new, inprogress dispersal' do
          expect { action }.to change { product1.dispersals.count }.by(1)
          expect(product1.reload.most_recent_dispersal(vendor).state).to eql('inprogress')
        end
      end
    end
  end

  describe '#update_scheduled' do
    let(:action) { get :update_scheduled, params: params }

    subject { action; JSON.parse response.body }

    it_behaves_like :unauthenticated

    context 'authenticated' do
      subject { action; JSON.parse response.body }

      include_context :authenticated_vendor

      let!(:config) do
        create :vendor_shop_dispersal_configuration,
               shop: shop,
               vendor: vendor,
               last_synced_at: 1.seconds.after
      end

      let!(:product6) { create :product, shop: shop, update_scheduled: true, original_sku: 'test' }

      it { is_expected.to eql ['original_sku' => product6.original_sku] }
    end
  end

  describe '#index' do
    let(:action) { get :index, params: params }

    it_behaves_like :unauthenticated

    context 'authenticated' do
      include_context :authenticated_vendor

      let!(:config) do
        create :vendor_shop_dispersal_configuration,
          shop: shop,
          vendor: vendor,
          last_synced_at: 1.minute.ago
      end

      let!(:shadow_product1) { create :shadow_product, product: product1, vendor_shop_configuration: config, enabled: true }
      let!(:shadow_product2) { create :shadow_product, product: product2, vendor_shop_configuration: config, enabled: true }
      let!(:shadow_product3) { create :shadow_product, product: product3, vendor_shop_configuration: config, enabled: true }
      let!(:shadow_product4) { create :shadow_product, product: product4, vendor_shop_configuration: config, enabled: true }
      let!(:shadow_product5) { create :shadow_product, product: product5, vendor_shop_configuration: config, enabled: true }

      let!(:match1) do
        create :vendor_product_match,
          product: product1,
          vendor_shop_configuration: config,
          matched: false
      end

      let!(:match2) do
        create :vendor_product_match,
          product: product2,
          vendor_shop_configuration: config,
          matched: true
      end

      let!(:match3) do
        create :vendor_product_match,
          product: product3,
          vendor_shop_configuration: config,
          matched: false
      end

      let!(:match4) do
        create :vendor_product_match,
          product: product4,
          vendor_shop_configuration: config,
          matched: true
      end

      let!(:match5) do
        create :vendor_product_match,
          product: product5,
          vendor_shop_configuration: config,
          matched: true
      end

      # exclude ones already inprogress
      let!(:dispersal1) do
        create :dispersal, vendor_shop_configuration: config, product: product1, state: :inprogress
      end

      # pending
      let!(:dispersal2) do
        create :dispersal, vendor_shop_configuration: config, product: product2, state: :completed, updated_at: 1.minute.ago
      end

      # exclude ones that has failed and haven't been resolved
      let!(:dispersal4) do
        create :dispersal, vendor_shop_configuration: config, product: product4, state: :failed
      end

      # exlude unmatched products
      let!(:dispersal3) do
        create :dispersal, vendor_shop_configuration: config, product: product3
      end

      # pending
      let!(:dispersal5) do
        create :dispersal, vendor_shop_configuration: config, product: product5, state: :pending
      end

      it_behaves_like :http_status, 200

      it_behaves_like :paginated

      it { expect(action).to match_response_schema 'vendors/products' }

      it 'lists only products valid for distribution' do
        merged_product2 = ProductMerger.new(product2, vendor: vendor).result
        merged_product5 = ProductMerger.new(product5, vendor: vendor).result

        action

        expected_json = [
          V1::Vendors::ProductBlueprint.render_as_hash(merged_product2, vendor: vendor, shop: product2.shop),
          V1::Vendors::ProductBlueprint.render_as_hash(merged_product5, vendor: vendor, shop: product5.shop),
        ].as_json.sort_by { |i| i['sku'] }.to_json

        expect(response.body).to eql expected_json
      end

      describe 'shadow product information' do
        let!(:shadow_product) do
          product2.shadow_product(vendor).update name: 'Hello'
        end

        it 'is merged into the product data' do
          action
          json = JSON.parse(response.body).detect { |j| j['sku'] == product2.sku }
          expect(json['name']).to eql 'Hello'
        end
      end

      describe 'master product information' do
        before do
          product2.update master: product5, color: nil
          product5.update color: 'Blue'
        end

        it 'is merged into the product data' do
          action
          json = JSON.parse(response.body).detect { |j| j['sku'] == product2.sku }
          expect(json['color']).to eql 'Blue'
        end
      end

      context 'soft-deleted shadow product' do
        before { shadow_product5.destroy }

        it 'skips the product' do
          merged_product2 = ProductMerger.new(product2, vendor: vendor).result

          action

          expected_json = [
            V1::Vendors::ProductBlueprint.render_as_hash(merged_product2, vendor: vendor, shop: product2.shop),
          ].as_json.sort_by { |i| i['sku'] }.to_json

          expect(response.body).to eql expected_json
        end
      end

      context 'filtering SKUs' do
        before { params[:skus] = [product2.sku, product5.sku].join(',') }

        it 'returns the filtered skus' do
          merged_product2 = ProductMerger.new(product2, vendor: vendor).result

          action

          skus = JSON.parse(response.body).collect { |pr| pr['sku'] }

          expect(skus).to eql [product2.sku, product5.sku]
        end
      end

      context 'fitering fields' do
        before { params[:fields] = :stock_count }

        it 'returns only the given fields' do
          action

          expected_json = [
            {
              sku: product2.sku,
              stock_count: 1,
            },
            {
              sku: product5.sku,
              stock_count: 1,
            },
          ].as_json.sort_by { |i| i['sku'] }.to_json

          expect(response.body).to eql expected_json
        end
      end

      context 'no channel product matches' do
        before { VendorProductMatch.delete_all }

        it 'returns no products' do
          action
          expect(response.body).to eql [].to_json
        end
      end
    end
  end
end
