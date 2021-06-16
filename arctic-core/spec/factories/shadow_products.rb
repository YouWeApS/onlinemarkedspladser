# frozen_string_literal: true

FactoryBot.define do
  factory :shadow_product do
    vendor_shop_configuration { create :vendor_shop_configuration }
    product { create :product }
  end
end
