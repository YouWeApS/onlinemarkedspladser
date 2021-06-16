# frozen_string_literal: true

FactoryBot.define do
  factory :product_error do
    shadow_product { create :shadow_product }
    message { 'Product error' }
    details { 'Details about the error' }
  end
end
