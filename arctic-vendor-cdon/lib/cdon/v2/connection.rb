# frozen_string_literal: true

require_relative '../../cdon'

class CDON::V2::Connection
  def initialize(api_key)
    url = 'https://mis.cdon.com'

    options = {
      headers: {
        'Authorization' => "api #{api_key}",
      },
    }

    Faraday.new url, options do |conn|
      conn.request :url_encoded
      conn.response :logger
      conn.adapter Faraday.default_adapter
    end
  end
end
