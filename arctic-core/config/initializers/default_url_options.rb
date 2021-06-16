# frozen_string_literal: true

default_url_options = {
  host: ENV.fetch('HOST', 'localhost'),
}

port = ENV.fetch('WEB_PORT', nil)
default_url_options[:port] = port if port.present?

Rails.application.routes.default_url_options = default_url_options

Rails.application.configure do |config|
  config.default_url_options = default_url_options
end
