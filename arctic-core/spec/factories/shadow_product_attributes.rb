# frozen_string_literal: true

FactoryBot.define do
  factory :shadow_product_attribute do
    shadow_product { create :shadow_product }
    field { 'name' }
    value { 'Overridden name' }
  end
end
