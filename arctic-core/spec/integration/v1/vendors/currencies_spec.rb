# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vendor products' do
  let(:shop) { create :shop }
  let(:shop_id) { shop.id }

  let!(:conversion) do
    create :currency_conversion,
      shop: shop,
      from_currency: :dkk,
      to_currency: :gbp,
      rate: 0.2
  end

  path '/v1/vendors/shops/{shop_id}/currencies' do
    include_context :swagger_authenticated_vendor

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    let!(:config) do
      create :vendor_shop_collection_configuration,
        shop: shop,
        vendor: vendor
    end

    get 'list currency conversions' do
      tags 'Currencies'

      description <<~STR.strip_heredoc
        List available currency exchange rates.
        If the dispersal vendor requires a currency that's not here it will use the European Centran Bank for the most recent currency conversion.
      STR

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/currency_conversions')
        end
      end
    end
  end

  path '/v1/vendors/shops/{shop_id}/currencies' do
    include_context :swagger_authenticated_vendor

    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    parameter \
      name: :conversion,
      in: :body,
      type: :array,
      required: true,
      description: 'Currency conversion information',
      schema: {
        type: :object,
        required: %i[from_currency to_currency rate],
        properties: {
          from_currency: {
            type: :string,
          },
          to_currency: {
            type: :string,
          },
          rate: {
            type: :string,
            format: :float,
          },
        },
      }

    let!(:config) do
      create :vendor_shop_collection_configuration,
        shop: shop,
        vendor: vendor
    end

    put 'update/create currency conversions' do
      tags 'Currencies'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        let(:conversion) do
          {
            from_currency: :dkk,
            to_currency: :gbp,
            rate: 1,
          }
        end
        run_test! do |response|
          expect(response).to match_response_schema('vendors/currency_conversion')
        end
      end
    end
  end
end
