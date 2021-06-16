# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Categories', swagger_doc: 'v1/ui/swagger.json' do
  let!(:config) { create :vendor_shop_dispersal_configuration }
  let!(:category_map) { create :category_map, vendor_shop_configuration: config }

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/categories' do
    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:account_id) { config.shop.account_id }

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

    get 'list categories' do
      include_context :swagger_authenticated_user, scopes: 'product:read'

      before { user.accounts << config.shop.account }

      tags 'Categories'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/category_maps')
        end
      end
    end

    post 'create a new category' do
      include_context :swagger_authenticated_user, scopes: 'product:write'

      before { user.accounts << config.shop.account }

      tags 'Categories'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      parameter \
        name: :body,
        in: :body,
        type: :object,
        required: true,
        description: 'Category details',
        schema: {
          type: :object,
          properties: {
            source: {
              type: :string,
            },
            value: {
              type: :object,
            },
          },
        }
      let(:body) do
        {
          source: '653',
          value: {
            browse_node: '2345678',
            variation_theme: 'Clothing',
            category: 'Clothing',
          },
        }
      end

      response 201, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/category_map')
        end
      end
    end
  end

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/categories/{id}' do
    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Vendor ID'
    let(:account_id) { config.shop.account_id }

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

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'Category ID'
    let(:id) { category_map.id }

    get 'show category details' do
      include_context :swagger_authenticated_user, scopes: 'product:read'

      before { user.accounts << config.shop.account }

      tags 'Categories'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/category_map')
        end
      end
    end

    delete 'delete category' do
      include_context :swagger_authenticated_user, scopes: 'product:write'

      before { user.accounts << config.shop.account }

      tags 'Categories'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      response 204, 'Success', example: true do
        run_test!
      end
    end

    patch 'update category' do
      include_context :swagger_authenticated_user, scopes: 'product:write'

      before { user.accounts << config.shop.account }

      tags 'Categories'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      parameter \
        name: :body,
        in: :body,
        type: :object,
        required: true,
        description: 'Category details',
        schema: {
          type: :object,
          properties: {
            source: {
              type: :string,
            },
            value: {
              type: :object,
            },
          },
        }
      let(:body) do
        {
          source: '653',
          value: {
            browse_node: '2345678',
            variation_theme: 'Clothing',
            category: 'Clothing',
          },
        }
      end

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/category_map')
        end
      end
    end
  end
end
