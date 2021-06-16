# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:sku) { |n| "#{n}#{SecureRandom.hex(6)}" }
    shop { create :shop }
    sequence(:name) { |n| "Product #{n}" }
    stock_count { 1 }
    description { 'Product description' }
    ean { SecureRandom.hex 6 }
    categories { %w[1 a] }

    trait :with_shadow_product do
      after :create do |prod|
        create :shadow_product, product: prod
      end
    end

    trait :with_images do
      after :build do |prod|
        prod.save!
        create :product_image, product: prod, position: 1, url: 'http://bit.ly/2SenX6K'
        create :product_image, product: prod, position: 2, url: 'http://bit.ly/2SenX6K'
        create :product_image, product: prod, position: 3, url: 'http://bit.ly/2SenX6K'
        prod.reload
      end
    end

    trait :with_prices do
      after :create do |prod|
        offer = create :product_price, cents: 1000, currency: 'USD'
        original = create :product_price, cents: 2000, currency: 'SEK'

        prod.update \
          original_price: original,
          offer_price: offer

        prod.reload
      end
    end

    trait :matched do
      after :create do |prod|
        prod.shop.vendor_shop_configurations.each do |config|
          VendorProductMatch.create! vendor_shop_configuration: config, product: prod
          ShadowProduct.create! vendor_shop_configuration: config, product: prod
        end
      end
    end
  end
end
