# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User ##{n}" }
    sequence(:email) { |n| "user#{n}@email.com" }
    password { 'password' }
    password_confirmation { 'password' }

    trait :with_password_reset_token do
      after :build do |u|
        u.password_reset_token = SecureRandom.uuid
        u.password_reset_token_expires_at = 30.minutes.from_now
        u.password_reset_redirect_to = 'https://localhost:8080/reset_password'
      end
    end
  end
end
