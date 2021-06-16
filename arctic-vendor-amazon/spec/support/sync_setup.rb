RSpec.shared_context :sync_setup do
  let(:shop1) do
    {
      id: 'a70b65e9-8ab5-4d1f-a4db-22eede34a276',
      auth_config: {
        merchant_id: 'A2IZEMSP8MNSVK',
        auth_token: 'amzn.mws.e4b41780-4aab-f06c-f2c8-a26fa022ba46',
      },
      collected_at: nil,
      config: {},
      product_parse_config: {},
    }
  end

  let(:shop2) do
    {
      id: '6baf9eb0-4887-4b3b-a05f-947e2f5c1372',
      auth_config: {
        merchant_id: 'AA3JE78TN61N1',
        auth_token: 'amzn.mws.86b2c7ac-a35f-b9ec-cdf2-c06a285ae024',
      },
      collected_at: nil,
      config: {},
      product_parse_config: {
        brand: {
          type: :string,
        },
        color: {
          type: :string,
        },
        manufacturer: {
          type: :string,
        },
        material: {
          type: :string,
        },
        size: {
          type: :string,
        },
        count: {
          type: :string,
        },
        gender: {
          type: :string,
        },
      },
    }
  end

  let(:products1) { [] }

  let(:products2) do
    path = File.expand_path '../fixtures/products2.json', __dir__
    json = File.read path
    JSON.parse json
  end
end
