# frozen_string_literal: true

FactoryBot.define do
  factory :shop do
    account { create :account }
    sequence(:name) { |n| "Shop #{n}" }

    trait :with_currency_conversions do
      after :create do |shop|
        create :currency_conversion,
          shop: shop,
          from_currency: 'DKK',
          to_currency: 'GBP',
          rate: 1.0

        shop.reload
      end
    end
  end
end
