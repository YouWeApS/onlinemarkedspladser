# frozen_string_literal: true

Mailgun.configure do |config|
  config.api_key = Rails.application.credentials.dig(:mailgun, :api_key)
end
