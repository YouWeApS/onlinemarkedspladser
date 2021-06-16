# frozen_string_literal: true

require 'swagger_helper'

shadow_product_note = <<~STR.strip_heredoc
  The shadow product which will be merged together with the original product
  information when the product is distributed.
STR

RSpec.describe 'UI Products', swagger_doc: 'v1/ui/swagger.json' do
  let(:account) { create :account, users: [user] }
  let!(:shop) { create :shop, account: account }
  let!(:vendor) { create :vendor }
  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }
  let!(:dispersal) { create :dispersal, product: product, state: :completed, vendor_shop_configuration: config }
  let!(:product) { create :product, shop: shop }
  let!(:shadow_product) { create :shadow_product, vendor_shop_configuration: config, product: product }

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/products/{id}' do
    include_context :swagger_authenticated_user, scopes: %w[product:read product:write]

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Account ID'
    let(:account_id) { account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:shop_id) { shop.id }

    parameter \
      name: :vendor_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:vendor_id) { vendor.id }

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'Product ID'
    let(:id) { shadow_product.id }

    get 'get product information' do
      description shadow_product_note

      tags 'Products'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/product')
        end
      end
    end

    delete 'delete product for this vendor' do
      tags 'Products'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      response 204, 'Deleted', example: true do
        run_test!
      end
    end

    patch 'update shadow product information' do
      description shadow_product_note

      tags 'Products'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      parameter \
        name: :body,
        in: :body,
        type: :object,
        required: true,
        description: 'Product details',
        schema: {
          type: :object,
          properties: {
            name: {
              type: :string,
            },
            description: {
              type: :string,
            },
          },
        }
      let(:body) do
        {
          name: 'Prodcut name for vendor',
          description: 'Prodcut description for vendor',
        }
      end

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/product')
        end
      end
    end
  end

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/products' do
    include_context :swagger_authenticated_user, scopes: 'product:read'

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true
    let(:account_id) { account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true
    let(:shop_id) { shop.id }

    parameter \
      name: :vendor_id,
      in: :path,
      type: :string,
      required: true
    let(:vendor_id) { vendor.id }

    get 'list products for shop' do
      tags 'Products'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/product_list_item')
        end
      end
    end
  end

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/products/import' do
    include_context :swagger_authenticated_user, scopes: 'product:write'

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Account ID'
    let(:account_id) { account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:shop_id) { shop.id }

    parameter \
      name: :vendor_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:vendor_id) { vendor.id }

    parameter \
      name: :file,
      in: :formData,
      type: :file,
      required: true,
      description: 'Product characteristics CSV file'
    let(:file) { fixture_file_upload('products.csv', 'text/csv') }

    put 'upload file to import product characteristics' do
      tags 'Import/export'

      consumes 'multipart/form-data'

      security [ oauth2: %w[product:write] ]

      response 202, 'Accepted', example: true do
        run_test!
      end
    end
  end

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/products/export' do
    include_context :swagger_authenticated_user, scopes: 'product:read'

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Account ID'
    let(:account_id) { account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:shop_id) { shop.id }

    parameter \
      name: :vendor_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:vendor_id) { vendor.id }

    get 'initiate product characteristics export' do
      tags 'Import/export'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 202, 'Accepted', example: true do
        run_test!
      end
    end
  end
end
