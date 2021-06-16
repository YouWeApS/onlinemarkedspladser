# frozen_string_literal: true

class Amazon::Credentials
  def self.parse(config)
    config.stringify_keys!

    keys = %w[
      merchant_id
      auth_token
    ]

    config.slice(*keys).tap do |hash|
      hash['aws_access_key_id'] = ENV['AWS_ACCESS_KEY_ID']
      hash['aws_secret_access_key'] = ENV['AWS_SECRET_ACCESS_KEY']
      hash['marketplace'] = ENV['MWS_MARKETPLACE_ID']
    end
  end
end
