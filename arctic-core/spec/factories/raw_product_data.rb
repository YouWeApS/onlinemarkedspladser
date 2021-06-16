# frozen_string_literal: true

FactoryBot.define do
  factory :raw_product_data do
    product { create :product }
  end
end
