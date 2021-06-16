# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    sequence(:order_id) { |n| "Order ##{n}" }
    shop { create :shop }
    vendor { create :vendor }
    billing_address { create :address }
    shipping_address { create :address }

    transient do
      product { create(:product) }
    end

    trait :with_order_lines do
      after :create do |order, evaluator|
        create :order_line, order: order, product: evaluator.product, status: :created
      end
    end
  end
end
