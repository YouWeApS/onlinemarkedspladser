# frozen_string_literal: true

amazon_config = {
  category_map_json_schema: {
    type: :object,
    required: %i[browser_node type classification variation_theme],
    properties: {
      browser_node: {
        title: 'Browser node ID',
        type: :string,
        format: :presence,
      },
      type: {
        title: 'Product type',
        type: :string,
        format: :presence,
      },
      classification: {
        title: 'Product subtype',
        type: :string,
        format: :presence,
      },
      variation_theme: {
        title: 'Variant theme',
        type: :string,
        format: :presence,
      },
    },
  },
  auth_config_schema: {
    type: :object,
    required: %w[
      merchant_id
      auth_token
    ],
    properties: {
      merchant_id: {
        type: 'string',
        format: :presence,
        title: 'Merchant ID',
      },
      auth_token: {
        type: :string,
        title: 'MWS Auth Token',
      },
    },
  },
  config_schema: {
    type: :object,
    required: [],
    properties: {},
  },
}

after 'development:clean' do
  FactoryBot.create :channel,
    id: '7804ac6b-41af-4d7f-bcc4-175eee2e1ace',
    name: 'Amazon',
    **amazon_config

  FactoryBot.create :channel,
    id: 'c69e5641-f5b7-47d3-bdef-7a30bfe5b347',
    name: 'Dandomain',
    auth_config_schema: {
      type: :object,
      required: %w[
        api_key
      ],
      properties: {
        api_key: {
          title: 'Dandomain V2 API key',
          type: :string,
          format: :presence,
        },
      },
    },
    config_schema: {
      type: :object,
      required: %w[
        host
        site_id
      ],
      properties: {
        host: {
          title: 'Dandomain site URL',
          type: :string,
          format: :url,
        },
        site_id: {
          title: 'Dandomain site ID',
          type: :number,
          format: :presence,
        },
        new_order_state_id: {
          title: 'Dandomain new order state ID',
          type: :string,
          format: :presence,
        },
        payment_methods: {
          title: 'Payment methods',
          type: :object,
        },
        shipping_methods: {
          title: 'Shipping methods',
          type: :object,
        },
      },
    }

  FactoryBot.create :channel,
    id: 'c82ba3f5-80e2-4646-8210-5ecea3971d27',
    name: 'CDON',
    auth_config_schema: {
      type: :object,
      required: %w[
        api_key
      ],
      properties: {
        api_key: {
          title: 'CDON API key',
          type: :string,
          format: :presence,
        },
      },
    },
    config_schema: {
      type: :object,
      required: %w[
        source_id
        report_id
      ],
      properties: {
        source_id: {
          title: 'CDON Source ID',
          type: :string,
          format: :presence,
        },
        report_id: {
          title: 'CDON orders report ID',
          type: :string,
          format: :presence,
        },
      },
    }
end
