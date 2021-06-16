FactoryBot.define do
  factory :order_invoice do
    order { create(:order) }
    invoice_id { SecureRandom.hex 6 }
    status { 'awaiting_payment' }
    cents { 1000 }
    currency { 'DKK' }
  end
end
