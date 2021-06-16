# frozen_string_literal: true

FactoryBot.define do
  factory :dispersal do
    product { create :product }
    vendor_shop_configuration { create :vendor_shop_configuration }

    trait :completed do
      after :build do |d|
        d.state = :completed
      end
    end
  end
end
