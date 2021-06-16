# frozen_string_literal: true

require 'logger'
require 'tempfile'
require 'net/http/post/multipart'

class CDON::V1::Feed
  Error = Class.new StandardError
  InvalidResponse = Class.new Error

  def submit
    return if skip_submit?

    import_id = upload_file
    start_processing import_id
    FileUtils.rm path if File.exist? path
  rescue Error => e
    Arctic.logger.error "Failed to process feed (#{e.class}): #{e.message}"
    Arctic.logger.info "Product XML left in #{path}"
    Rollbar.error e
  end

  private

    def skip_submit?
      false
    end

    def start_processing(import_id)
      message = make_import_processing_request import_id
      Arctic.logger.info "Started processing Import ID: #{import_id}: #{message}"
    end

    def make_import_processing_request(import_id)
      conn = Faraday.new(url: url, headers: import_processing_headers) do |f|
        f.request :json
        f.adapter :net_http
      end
      res = conn.put('api/importfile') do |req|
        req.params['importFileId'] = import_id
      end
      parse_import_processing_response res
    end

    def import_processing_headers
      {
        'Authorization' => "api #{api_key}",
      }
    end

    def parse_import_processing_response(response)
      json = JSON.parse response.body

      success = json['success']
      err = "#{json.fetch('ErrorCode', 'Unknown code')}: #{json.fetch('Message', 'Unknown error')}"
      raise InvalidResponse, err unless success

      json['message']
    end

    def upload_file
      res = post_file_http_request

      json = JSON.parse res.body

      import_id = json.fetch('ImportId', nil)

      err = "#{json.fetch('ErrorCode', 'Unknown code')}: #{json.fetch('Message', 'Unknown error')}"
      raise InvalidResponse, err if import_id.blank?

      Arctic.logger.info "POSTed xml file to api/importfile. Import ID: #{import_id}"

      import_id
    end

    def url
      ENV.fetch('MARKETPLACE_URL', 'https://integration-admin.marketplace.cdon.com')
    end

    def api_key
      shop.fetch('auth_config', {}).fetch('api_key')
    end

    def path
      @path ||= begin
        tmp_dir = $root.join 'tmp'
        tmp_dir.join("#{SecureRandom.hex(8)}.xml").tap do |s|
          FileUtils.mkdir_p File.dirname(s)
          File.open(s, 'wb') { |f| f.write to_xml }
        end
      end
    end

    def post_file_http_request
      uri = URI.parse "#{url.to_s.chomp('/')}/api/importfile"

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post::Multipart.new uri.path,
          data: UploadIO.new(File.open(path), 'application/xml', 'products.xml')

        req.add_field('Authorization', "api #{api_key}")

        http.request req
      end
    end
end
