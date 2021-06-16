# frozen_string_literal: true

FactoryBot.define do
  factory :category_map do
    vendor_shop_configuration { create :vendor_shop_configuration }
    value { { group: :a } }
    source { 'a' }
  end
end
