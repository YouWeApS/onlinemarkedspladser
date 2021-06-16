# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Products', swagger_doc: 'v1/ui/swagger.json' do
  let!(:config) { create :vendor_shop_dispersal_configuration }
  let!(:product) { create :product, shop: config.shop }
  let!(:shadow_product) { create :shadow_product, product: product, vendor_shop_configuration: config }
  let!(:error) { create :product_error, shadow_product: shadow_product }

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/products/{product_id}/errors/{id}' do
    include_context :swagger_authenticated_user, scopes: 'product:write'

    before { user.accounts << config.shop.account }

    parameter \
      name: :product_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Product ID'
    let(:product_id) { shadow_product.id }

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'Product Error ID'
    let(:id) { error.id }

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:account_id) { config.shop.account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:shop_id) { config.shop.id }

    parameter \
      name: :vendor_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:vendor_id) { config.vendor_id }

    delete 'resolve and close error' do
      tags 'Product Errors'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/product')
        end
      end
    end
  end

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/products/{product_id}/errors/destroy_all' do
    include_context :swagger_authenticated_user, scopes: 'product:write'

    before { user.accounts << config.shop.account }

    parameter \
      name: :product_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Product ID'
    let(:product_id) { shadow_product.id }

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:account_id) { config.shop.account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:shop_id) { config.shop.id }

    parameter \
      name: :vendor_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:vendor_id) { config.vendor_id }

    delete 'resolve and close all errors' do
      tags 'Product Errors'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/product')
        end
      end
    end
  end
end
