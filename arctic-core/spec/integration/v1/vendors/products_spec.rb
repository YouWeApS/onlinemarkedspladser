# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vendor products' do
  include_context :swagger_authenticated_vendor

  let(:shop) { create :shop }
  let(:shop_id) { shop.id }
  let!(:product1) { create :product, :with_prices, shop: shop }
  let!(:product2) { create :product, :with_prices, :with_images, shop: shop }
  let!(:dispersal2) { create :dispersal, product: product2, vendor_shop_configuration: config }

  path '/v1/vendors/shops/{shop_id}/products' do
    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    let!(:category_map) do
      create :category_map,
        source: :a,
        value: { group: :Clothing },
        vendor_shop_configuration: config
    end

    get 'products for dispersal' do
      let!(:config) do
        create :vendor_shop_dispersal_configuration,
          shop: shop,
          vendor: vendor
      end

      let!(:shadow1) do
        create :shadow_product,
          product: product1,
          vendor_shop_configuration: config,
          enabled: true
      end

      let!(:shadow2) do
        create :shadow_product,
          product: product2,
          vendor_shop_configuration: config,
          enabled: true
      end

      let!(:match1) do
        create :vendor_product_match,
          product: product1,
          vendor_shop_configuration: config,
          matched: true
      end

      let!(:match2) do
        create :vendor_product_match,
          product: product2,
          vendor_shop_configuration: config,
          matched: true
      end

      tags 'Products'

      description <<~STR.strip_heredoc
        Additional params:

        * `fields`: An exclusive, comma-separeted list of fields to display in the JSON output.
      STR

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/products')
          skus = JSON.parse(response.body).collect { |prod| prod['sku'] }
          expect(skus).to match_array skus
        end
      end
    end

    post 'create/update product for collection' do
      let!(:config) do
        create :vendor_shop_collection_configuration,
          shop: shop,
          vendor: vendor
      end

      parameter \
        name: :product,
        in: :body,
        schema: {
          type: :object,
          required: %i[sku name],
          properties: {
            sku: {
              type: :string,
              format: :present,
              required: true,
            },
            name: {
              type: :string,
              format: :present,
              required: true,
            },
            categories: {
              type: :array,
              minItems: 1,
              items: {
                type: :string,
              },
            },
            original_price: {
              type: :object,
              properties: {
                cents: {
                  type: :string,
                },
                currency: {
                  type: :string,
                },
              },
            },
            offer_price: {
              type: :object,
              properties: {
                cents: {
                  type: :string,
                },
                currency: {
                  type: :string,
                },
                expires_at: [nil, 'string'],
              },
            },
            images: {
              type: :array,
              minItems: 1,
              items: {
                type: :string,
              },
            },
            remove: {
              type: :boolean,
              default: false,
            },
            raw_data: {
              type: :object,
              required: true,
              description: 'Raw data as received by the channel formatted as JSON',
            },
          },
        }

      let(:product) do
        {
          sku: 'Black carapace L',
          name: 'Black carapace',
          categories: ['a', 1],
          images: ['http://google.com?a=b'],
          original_price: {
            cents: 200,
            currency: 'DKK',
          },
          offer_price: {
            cents: 100,
            currency: 'DKK',
            expires_at: 14.days.from_now.httpdate,
          },
          raw_data: {
            NAME: 'Black carapace',
          },
        }
      end

      tags 'Products'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      description <<~STR.strip_heredoc
        ### Remove a product

        To remove a product from distribution set the `remove` parameter to `true`.
        If set on a non-existing product, the product will be skipped, otherwise the product will be deleted.
        This forces a 204 No Content response.

        ### Time constrained offer prices

        If you want to create a temporary price for the product (e.g. christmas offer) set the `expires_at` to a database formatted datetime and the product's price will automatically change to the last known price without an `expires_at` when the current offer price expires.
      STR

      response 201, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/product')
        end
      end
    end
  end

  path '/v1/vendors/shops/{shop_id}/products/{sku}' do
    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    parameter \
      name: :sku,
      in: :path,
      type: :string,
      required: true,
      description: 'Product SKU'

    let(:sku) { product1.sku }

    parameter \
      name: :data,
      in: :body,
      type: :object,
      required: true,
      description: 'Product information to update',
      schema: {
        type: :object,
        properties: {
          dispersed_at: {
            type: :string,
            format: :datetime,
          },
        },
      }

    let(:data) do
      {
        dispersed_at: Time.zone.now.httpdate,
      }
    end

    let!(:config) do
      create :vendor_shop_dispersal_configuration,
        shop: shop,
        vendor: vendor
    end

    patch 'update product information' do
      tags 'Products'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/product')
        end
      end
    end
  end
end
