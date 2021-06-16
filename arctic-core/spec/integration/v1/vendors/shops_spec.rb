# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vendor shops' do
  let(:dispersal_shop) { create :shop }
  let(:collection_shop) { create :shop }

  path '/v1/vendors/shops' do
    include_context :swagger_authenticated_vendor

    let!(:dispersal_config) { create :vendor_shop_dispersal_configuration, shop: dispersal_shop, vendor: vendor }
    let!(:collection_config) { create :vendor_shop_collection_configuration, shop: collection_shop, vendor: vendor }

    get 'collection and dispersal shops' do
      tags 'Shops'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/shops')
        end
      end
    end
  end

  path '/v1/vendors/shops/{id}/products_synced' do
    include_context :swagger_authenticated_vendor

    let!(:dispersal_config) { create :vendor_shop_dispersal_configuration, shop: dispersal_shop, vendor: vendor }
    let!(:collection_config) { create :vendor_shop_collection_configuration, shop: collection_shop, vendor: vendor }

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:id) { dispersal_shop.id }

    patch 'Report when the vendor completed its run for this shop' do
      tags 'Shops'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 204, 'Success', example: true do
        run_test!
      end
    end
  end

  path '/v1/vendors/shops/{id}/orders_synced' do
    include_context :swagger_authenticated_vendor

    let!(:dispersal_config) { create :vendor_shop_dispersal_configuration, shop: dispersal_shop, vendor: vendor }
    let!(:collection_config) { create :vendor_shop_collection_configuration, shop: collection_shop, vendor: vendor }

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:id) { dispersal_shop.id }

    patch 'Report when the vendor completed its run for this shop' do
      tags 'Orders'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 204, 'Success', example: true do
        run_test!
      end
    end
  end
end
