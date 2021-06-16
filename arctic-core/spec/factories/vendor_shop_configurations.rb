# frozen_string_literal: true

FactoryBot.define do
  factory :vendor_shop_configuration do
    vendor { create :vendor }
    shop { create :shop }
    auth_config { { password: :secret } }
    currency_config { { currency: 'GBP' } }

    trait :with_webhooks do
      after :build do |c|
        c.webhooks = {
          product_created: 'https://somewhere.com/product_created',
          product_updated: 'https://somewhere.com/product_updated',
          shadow_product_updated: 'https://somewhere.com/shadow_product_updated',
        }
      end
    end
  end
end
