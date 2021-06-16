# frozen_string_literal: true

FactoryBot.define do
  factory :currency_conversion do
    shop { create :shop }
    from_currency { 'DKK' }
    to_currency { 'USD' }
    rate { 1.5 }
  end
end
