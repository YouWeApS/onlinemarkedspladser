# frozen_string_literal: true

# Usage: pry -r ./manual_test.rb

require_relative './lib/cdon'

p1 = {
  sku: 'abcdef123',
  stock_count: 1,
  offer_price: {
    cents: 1000,
    currency: 'SEK',
  },
  original_price: {
    cents: 2000,
    currency: 'SEK',
  },
  name: 'Product 1',
  ean: 'ean-123',
  description: 'This is a cool product',
  categories: [
    {
      id: :Sneakers,
    },
  ],
}

p2 = {
  sku: 'hijklm456',
  stock_count: 1,
  offer_price: {
    cents: 1000,
    currency: 'SEK',
  },
  original_price: {
    cents: 2000,
    currency: 'SEK',
  },
  name: 'Product 2',
  ean: 'ean-456',
  description: 'This is another cool product',
  color: 'black',
  categories: [
    {
      id: :Sneakers,
      variations: %w[color],
    },
  ],
}

p3 = {
  sku: 'hijklm457',
  stock_count: 1,
  offer_price: {
    cents: 1000,
    currency: 'SEK',
  },
  original_price: {
    cents: 2000,
    currency: 'SEK',
  },
  name: 'Product 2a',
  ean: 'ean-789',
  description: 'This is a variation of a cool product',
  master_sku: 'hijklm456',
  color: 'grey',
  categories: [
    {
      id: :Sneakers,
    },
  ],
}

shop = {
  config: {
    source_id: 'xxx',
    country: 'se',
    vat: 25.00,
  },

  auth_config: {
    api_key: '9041c071-145a-42f5-948a-1fe68b8790cf',
  },
}

px = CDON::V1::Products.new shop, [p1, p2, p3]

File.open('products.xml', 'wb') { |f| f.write px.to_xml }

puts 'products.xml generated. Goto https://integration-admin.marketplace.cdon.com/Import and upload it'

exit
