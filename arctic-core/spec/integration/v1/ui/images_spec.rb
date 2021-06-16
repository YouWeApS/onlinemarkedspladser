# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Products', swagger_doc: 'v1/ui/swagger.json' do
  let(:account) { create :account, users: [user] }
  let!(:shop) { create :shop, account: account }
  let!(:product) { create :product, shop: shop }
  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }
  let!(:vendor) { create :vendor }
  let!(:dispersal) { create :dispersal, product: product, state: :completed }
  let!(:shadow_product) { create :shadow_product, vendor_shop_configuration: config, product: product }
  let!(:image) { create :product_image, product: product }

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/products/{product_id}/images/{id}' do
    include_context :swagger_authenticated_user, scopes: %w[product:write]

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
      description: 'Image ID'
    let(:id) { image.id }

    patch 'update image position' do
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
            position: {
              type: :integer,
            },
          },
        }
      let(:body) do
        {
          position: 2,
        }
      end

      response 200, 'Success', example: true do
        run_test!
      end
    end
  end
end
