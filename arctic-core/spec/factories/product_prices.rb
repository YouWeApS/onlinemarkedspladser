# frozen_string_literal: true

FactoryBot.define do
  factory :product_price do
    cents { 1 }
    currency { 'DKK' }
    expires_at { nil }

    trait :expired do
      after :build do |pp|
        pp.expires_at = 1.minute.ago
      end
    end
  end
end
