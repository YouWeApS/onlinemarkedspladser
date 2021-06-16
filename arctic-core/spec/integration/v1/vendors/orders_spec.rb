# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vendor orders' do
  include_context :swagger_authenticated_vendor

  let(:shop) { create :shop }
  let(:shop_id) { shop.id }
  let(:product) { create :product, shop: shop }

  let!(:existing_order) do
    create :order, :with_order_lines, shop: shop, vendor: vendor
  end

  let!(:config) do
    create :vendor_shop_dispersal_configuration,
      shop: shop,
      vendor: vendor
  end

  let(:order) do
    {
      order_id: 'AZ1',
      payment_reference: 'abcdef123',

      currency: 'CAD',

      payment_fee: 111,
      shipping_fee: 222,

      raw_data: {
        complete: {
          raw: {
            order: :data,
          },
        },
      },

      order_lines_attributes: [
        {
          line_id: 1,
          product_id: product.sku,
          quantity: 1,
          cents_with_vat: 12000,
          cents_without_vat: 10000,
        },
      ],

      billing_address: {
        name: 'Bob The Builder',
        address1: 'Somewhere 1',
        city: 'Copenhagen',
        country: 'DK',
        zip: 1234,
        phone: '+4512345678',
        email: 'bob@builder.com',
      },

      shipping_address: {
        name: 'Bob The Builder',
        address1: 'Somewhere else 2',
        city: 'Copenhagen',
        country: 'DK',
        zip: 1234,
        phone: '+4512345678',
        email: 'bob@builder.com',
      },
    }
  end

  path '/v1/vendors/shops/{shop_id}/orders' do
    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    get 'List orders' do
      tags 'Orders'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/orders')
        end
      end
    end
  end

  path '/v1/vendors/shops/{shop_id}/orders/{id}' do
    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'Order ID'

    parameter \
      name: :order,
      in: :body,
      type: :object,
      required: true,
      description: 'Order information',
      schema: {
        type: :object,
        properties: {
          receipt_id: {
            type: :string,
          },
          track_and_trace_reference: {
            type: :string,
          },
          currency: {
            type: :string,
          },
          payment_fee: {
            type: :string,
          },
          shipping_fee: {
            type: :string,
          },
        },
      }

    patch 'Update order' do
      description <<~STR.strip_heredoc
        ### Track and trace reference

        While the order it self does not contain track and trace references, because it's the most common usage to ship all items in an order at the same time, we expose the option to PATCH the track_and_trace_reference on the order, which will update ALL order lines' status to "shipped" and set the track_and_trace_reference on each of them.
      STR

      tags 'Orders'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      let(:id) { existing_order.id }

      let(:order) do
        {
          receipt_id: 'abcdef123',
          track_and_trace_reference: 'hhhh123',
          currency: 'SEK',
          shipping_fee: 999,
          payment_fee: 888,
        }
      end

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/order')
          expect(JSON.parse(response.body)['receipt_id']).to eql 'abcdef123'
          expect(JSON.parse(response.body)['currency']).to eql 'SEK'
          expect(JSON.parse(response.body)['payment_fee']).to eql '8.88'
          expect(JSON.parse(response.body)['shipping_fee']).to eql '9.99'
          expect(JSON.parse(response.body)['order_lines'][0]['track_and_trace_reference']).to eql 'hhhh123'
        end
      end
    end
  end


  path '/v1/vendors/shops/{shop_id}/orders' do
    parameter \
      name: :shop_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Shop ID'

    parameter \
      name: :order,
      in: :body,
      type: :object,
      required: true,
      description: 'Order information',
      schema: {
        type: :object,
        properties: {
          order_id: {
            type: :string,
          },
          payment_reference: {
            type: :string,
          },
          total: {
            type: :string,
          },
          currency: {
            type: :string,
          },
          order_lines_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: {
                  type: :string,
                  format: :presence,
                },

                line_id: {
                    type: :integer,
                    format: :presence,
                },

                quantity: {
                  type: :integer,
                  format: :presence,
                },

                cents_without_vat: {
                  type: :integer,
                },

                cents_with_vat: {
                  type: :integer,
                },
              },
            },
          },
          shipping_address: {
            description: [
              'Omitting this entirely will use the billing address in-place of',
              'the missing shipment address.',
            ].join(' '),
            type: :object,
            requires: %w[name address1 city country zip phone email],
            properties: {
              name: {
                type: :string,
                required: true,
              },
              address1: {
                type: :string,
                required: true,
              },
              city: {
                type: :string,
                required: true,
              },
              country: {
                type: :string,
                required: true,
              },
              zip: {
                type: :string,
                required: true,
              },
              phone: {
                type: :string,
                required: true,
              },
              email: {
                type: :string,
                required: true,
              },
            },
          },
          billing_address: {
            required: true,
            type: :object,
            requires: %w[name address1 city country zip phone email],
            properties: {
              name: {
                type: :string,
                required: true,
              },
              address1: {
                type: :string,
                required: true,
              },
              city: {
                type: :string,
                required: true,
              },
              country: {
                type: :string,
                required: true,
              },
              zip: {
                type: :string,
                required: true,
              },
              phone: {
                type: :string,
                required: true,
              },
              email: {
                type: :string,
                required: true,
              },
            },
          },
        },
      }

    post 'Create new order' do
      tags 'Orders'

      consumes 'application/json'
      produces 'application/json'

      security [ basic: [] ]

      response 201, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('vendors/order')

          json = JSON.parse(response.body)

          expect(json.dig('status')).to include 'created'
          expect(json.dig('payment_reference')).to eql 'abcdef123'
          expect(json.dig('billing_address', 'address1')).to eql 'Somewhere 1'
          expect(json.dig('shipping_address', 'address1')).to eql 'Somewhere else 2'
          expect(json.dig('total')).to eql '123.33'
          expect(json.dig('total_without_vat')).to eql '103.33'

          ol = OrderLine.order(created_at: :desc).first
          expect(json.dig('order_lines', 0)).to eql({
            id: ol.id,
            status: :created,
            line_id: '1',
            product_id: product.sku,
            track_and_trace_reference: nil,
            quantity: 1,
            cents_with_vat: 12000,
            cents_without_vat: 10000,
          }.as_json)
        end
      end
    end
  end
end
