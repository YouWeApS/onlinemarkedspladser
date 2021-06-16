# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI VendorShopConfiguration', swagger_doc: 'v1/ui/swagger.json' do
  let(:config) { create :vendor_shop_dispersal_configuration }

  path '/v1/ui/accounts/{account_id}/shops/{shop_id}/vendors/{vendor_id}/config' do
    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:account_id) { config.shop.account.id }

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:shop_id) { config.shop.id }

    parameter \
      name: :vendor_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'
    let(:vendor_id) { config.vendor.id }

    get 'vendor/shop configuration settings' do
      include_context :swagger_authenticated_user, scopes: 'product:read'
      before { user.accounts << config.shop.account }

      tags 'Shops'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/vendor')
        end
      end
    end

    patch 'vendor/shop configuration settings' do
      description \
        <<~STR.strip_heredoc
          The `auth_config` section of the vendor/shop configuration object will \
          be validated against the schema defined by the sales channel.
        STR

      include_context :swagger_authenticated_user, scopes: 'product:write'
      before { user.accounts << config.shop.account }

      parameter \
        name: :body,
        in: :body,
        type: :object,
        required: true,
        description: 'Configuration details',
        schema: {
          type: :object,
          properties: {
            auth_config: {
              type: :object,
            },
            currency_config: {
              type: :object,
            },
            config: {
              type: :object,
            },
            enabled: {
              type: :boolean,
            },
            price_adjustment_type: {
              type: :string,
            },
            price_adjustment_value: {
              type: :string,
            },
            webhooks: {
              type: :object,
              properties: {
                product_created: {
                  type: :string,
                },
                product_updated: {
                  type: :string,
                },
                shadow_product_updated: {
                  type: :string,
                },
              },
            }
          },
        }
      let(:body) do
        {
          auth_config: {
            key: :value,
          },
          currency_config: {
            currency: 'GBP',
          },
          config: {
            shop_id: 1,
          },
          enabled: true,
          price_adjustment_type: :percent,
          price_adjustment_value: 10,
          webhooks: {
            product_created: 'https://somewhere.com',
          },
        }
      end

      tags 'Shops'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:write] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/vendor')
        end
      end
    end
  end
end
