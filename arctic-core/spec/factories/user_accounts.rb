# frozen_string_literal: true

FactoryBot.define do
  factory :user_account do
    account { create :account }
    user { create :user }
  end
end
