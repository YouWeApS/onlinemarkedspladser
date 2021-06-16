# frozen_string_literal: true

FactoryBot.define do
  factory :product_image do
    sequence(:url) { |n| "https://google.com?q=#{n}" }
    position { 1 }
    product { create :product }
  end
end
