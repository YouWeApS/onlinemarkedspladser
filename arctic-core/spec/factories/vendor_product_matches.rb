# frozen_string_literal: true

FactoryBot.define do
  factory :vendor_product_match do
    product { create :product }
    vendor_shop_configuration { create :vendor_shop_configuration }
  end
end
