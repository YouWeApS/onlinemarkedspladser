# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vendor products' do
  include_context :swagger_authenticated_vendor

  let(:shop) { create :shop }
  let(:shop_id) { shop.id }
  let!(:product1) { create :product, :with_prices, shop: shop }

  path '/v1/vendors/shops/{shop_id}/products/{sku}/errors' do
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
      name: :error,
      in: :body,
      type: :object,
      required: true,
      description: 'Product error information',
      schema: {
        type: :object,
        requires: %i[message details],
        properties: {
          message: {
            type: :string,
          },
          details: {
            type: :string,
          },
          severity: {
            type: :string,
            enum: %w[error warning],
          },
        },
      }

    let(:error) do
      {
        message: 'Some error',
        details: 'Error details',
      }
    end

    let!(:config) do
      create :vendor_shop_dispersal_configuration,
        shop: shop,
        vendor: vendor
    end

    post 'add error to products' do
      tags 'Products'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test!
      end
    end
  end
end
