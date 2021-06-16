FactoryBot.define do
  factory :order_line do
    sequence(:line_id) { |n| n }
    order { create(:order) }
    status { "created" }
    product { create(:product) }
    quantity { 1 }
    track_and_trace_reference { SecureRandom.hex 16 }
    cents_with_vat { 12000 }
    cents_without_vat { 10000 }
  end
end
