# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    name { Faker::Name.name }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    zip { Faker::Address.zip_code }
    country { Faker::Address.country_code }
    city { Faker::Address.city }
    phone { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
  end
end
