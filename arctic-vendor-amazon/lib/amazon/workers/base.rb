# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

class Amazon::Workers::Base
  include Sidekiq::Worker

  sidekiq_options \
    retry: false, # don't retry
    dead: false # skip dead queue

  sidekiq_retries_exhausted do |msg, ex|
    Arctic.logger.fatal "Unable to run #{msg['class']}(#{msg['args']}): #{msg['error_message']}"
    Rollbar.fatal ex
  end

  attr_reader :shop_id, :feed_id, :options

  # rubocop:disable Metrics/AbcSize

  def perform(shop_id, options = {})
    extract_options options
    @shop_id = shop_id

    Arctic.logger.info "#{log_msg}: #{products.size} products"

    return if products.empty?

    update_states

    feed = submit_feed
    if feed
      @feed_id = extract_feed_id feed
      path = archive_xml 'submitted'
      Arctic.logger.info "#{log_msg}: Feed ID: #{feed_id}: #{path}"

      remove_failed_products
    end

    completed

    submit_next if options["continue"]
  end

  # rubocop:enable Metrics/AbcSize

  private

    def completed
      update_states :ready
      core_api.synced(shop_id, :products) unless options["continue"]
      Arctic.logger.info "Completed #{self}(#{feed_id}) for Shop(#{shop_id})/#{marketplace}"
    end

    def submit_next
      raise NotImplementedError, 'descendents must implement this'
    end

    def update_states(state = :inprogress)
      products.each do |prod|
        Amazon::Workers::ProductState.perform_async shop_id, prod['sku'], state
      end
    end

    def remove_failed_products
      errors = response_errors(feed_id)
      Arctic.logger.warn "Found #{errors.size} errors for #{self}(#{feed_id})"

      errors.each do |error_hash|
        handle_error error_hash
      end
    end

    def handle_error(error_hash)
      sku = error_hash.fetch('AdditionalInfo', {}).fetch('SKU', nil)
      severity = error_hash['ResultCode'].to_s.downcase
      message = error_hash['ResultDescription']

      Amazon::Workers::ProductError.perform_async shop_id, sku,
        severity: severity,
        message: message

      fail_product sku if severity == 'error'
    end

    def fail_product(sku)
      Amazon::Workers::ProductState.perform_async shop_id, sku, :failed
    end

    def extract_options(options)
      @options = {
        continue: false,
      }.merge options
    end

    def shop
      @shop ||= core_api.get_shop(shop_id).as_json
    end

    def core_api
      @core_api ||= Arctic::Vendor::Dispersal::API.new
    end

    def products
      @products ||= core_api.list_products shop_id
    end

    def credentials
      @credentials ||= Amazon::Credentials.parse shop['auth_config']
    end

    def client
      @client = MWS::Feeds::Client.new credentials
    end

    def extract_feed_id(response)
      Hash
        .from_xml(response.body, {})
        .fetch('SubmitFeedResponse', {})
        .fetch('SubmitFeedResult', {})
        .fetch('FeedSubmissionInfo', {})
        .fetch('FeedSubmissionId', nil)
    end

    # rubocop:disable Style/RescueStandardError

    def feed_response(feed_id)
      10.times do |i|
        begin
          body = client.get_feed_submission_result(feed_id).body
          archive_xml 'response', body
          return body
        rescue => e
          case e.class.to_s
          when /Peddler\:\:Errors/ then nil # noop
          else raise e
          end
        end

        n = 3 + (i * 2)
        sleep n.minutes
      end
    end

    def response_errors(feed_id)
      results = Hash
        .from_xml(feed_response(feed_id))
        .fetch('AmazonEnvelope', {})
        .fetch('Message', {})
        .fetch('ProcessingReport', {})
        .fetch('Result', [])
      [results].flatten(1).compact
    end

    # rubocop:enable Style/RescueStandardError

    def marketplace
      @marketplace ||= credentials.fetch 'marketplace'
    end

    def submit_feed
      my_xml = xml
      client.submit_feed my_xml, self.class::FEED_TYPE, marketplace_id_list: marketplace if my_xml
    end

    def archive_xml(type, xml_content = xml)
      options = { subdir: "#{type}/#{self.class::FEED_TYPE}" }
      id = feed_id.present? ? "-#{feed_id}" : nil
      name = "#{Time.now.to_s(:db)}#{id}"
      Amazon::Archive.new(name, xml_content, options).tap do |a|
        a.save
        return a.path
      end
    end

    def xml
      @xml ||= begin
        envelope_options = {
          credentials: credentials.symbolize_keys,
          operation: 'Update',
          import_map: shop.fetch('product_parse_config', []),
        }
        klass = "Amazon::XML::Envelope::#{self.class::ENVELOPE_CLASS}".constantize
        klass.new(products, envelope_options).to_xml
      end
    end
end

# rubocop:enable Metrics/ClassLength
