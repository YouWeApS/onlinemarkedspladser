# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    sequence(:name) { |n| "Channel #{n}" }
    auth_config_schema { { type: :object } }
  end
end
