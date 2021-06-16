# frozen_string_literal: true

FactoryBot.define do
  factory :vendor do
    token { SecureRandom.uuid }
    channel { create :channel }
    validation_url { 'http://localhost:9292/validate' }

    trait :amazon do
      after :build do |v|
        v.id = 'ac2d3139-100a-4011-8ca0-2670fd2ec35b'
        v.token = '64cf21de-db7a-4370-982a-0d5f14d90c61'
      end
    end
  end
end
