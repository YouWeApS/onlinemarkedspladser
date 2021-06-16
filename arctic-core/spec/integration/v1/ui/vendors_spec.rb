# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Vendors', swagger_doc: 'v1/ui/swagger.json' do
  path '/v1/ui/vendors/' do
    let!(:vendor1) { create :vendor }
    let!(:vendor2) { create :vendor }

    let(:shop) { create :shop }
    let!(:config1) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor1 }
    let!(:config2) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor2 }

    get 'list all vendors' do
      include_context :swagger_authenticated_user, scopes: 'product:read'

      tags 'Vendors'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      parameter \
        name: :shop_id,
        in: :query,
        type: :string,
        description: 'Shop ID'
      let(:shop_id) { shop.id }

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/vendors')
        end
      end
    end
  end

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors' do
    let!(:vendor1) { create :vendor }
    let!(:vendor2) { create :vendor }

    let(:shop) { create :shop }
    let!(:config1) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor1 }
    let!(:config2) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor2 }

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      description: 'Shop ID'
    let(:account_id) { shop.account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      description: 'Shop ID'
    let(:shop_id) { shop.id }

    get 'list vendors for the shop' do
      include_context :swagger_authenticated_user, scopes: 'product:read'

      before { user.accounts << shop.account }

      tags 'Vendors'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/vendors')
        end
      end
    end
  end
end
