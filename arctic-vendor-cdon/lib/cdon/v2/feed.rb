# frozen_string_literal: true

class CDON::V2::Feed
  def submit
    connection.put endpoint, to_xml
  end

  private

    def endpoint
      raise NotImplementedError, 'descendent must implement this'
    end

    def url
      ENV.fetch('MARKETPLACE_URL', 'https://mis.cdon.com/api')
    end

    def connection
      @connection ||= Faraday.new url, faraday_options do |conn|
        conn.request  :url_encoded
        conn.response :logger
        conn.adapter  Faraday.default_adapter
      end
    end

    def faraday_options
      {
        headers: {
          'Authorization' => "api #{options.api_key}",
        },
      }
    end
end
