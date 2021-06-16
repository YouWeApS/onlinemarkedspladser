# frozen_string_literal: true

require_relative 'production'

Rails.application.configure do
  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  config.action_cable.allowed_request_origins = [
    /localhost/,
    'https://staging.merchant.yourdomain.com',
  ]
end
