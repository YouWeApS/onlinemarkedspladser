# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vendor orders' do
  include_context :swagger_authenticated_vendor

  let(:shop) { create :shop }
  let(:shop_id) { shop.id }
  let(:order) { create :order, shop: shop }
  let(:order_id) { order.id }
  let(:product) { create :product, shop: shop }
  let(:order_line) { create :order_line, order: order, product: product }
  let(:id) { order_line.id }

  let!(:config) do
    create :vendor_shop_dispersal_configuration,
      shop: shop,
      vendor: vendor
  end

  path '/v1/vendors/shops/{shop_id}/orders/{order_id}/order_lines/statuses' do
    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    parameter \
      name: :order_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Order ID'

    get 'Possible order line statuses' do
      tags 'Orders'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(JSON.parse(response.body)).to match_array OrderLine::STATUSES.keys
        end
      end
    end
  end

  path '/v1/vendors/shops/{shop_id}/orders/{order_id}/order_lines/{id}' do
    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    parameter \
      name: :order_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Order ID'

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'Order line ID'

    parameter \
      name: :order_line,
      in: :body,
      type: :object,
      required: true,
      description: 'Order line information',
      schema: {
        type: :object,
        properties: {
          track_and_trance_reference: {
            type: :string,
          },
          line_id: {
            type: :string,
          },
          status: {
            type: :string,
          },

          cents_with_vat: {
            type: :integer,
          },

          cents_without_vat: {
            type: :integer,
          },
        },
      }

    patch 'Update order line' do
      tags 'Orders'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/order_line')
        end
      end
    end
  end
end
