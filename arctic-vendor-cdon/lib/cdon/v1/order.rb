# frozen_string_literal: true

require 'faraday_curl'

class CDON::V1::Order
  attr_reader :shop, :data

  def initialize(shop, data = {})
    @data = data
    @shop = shop.as_json
  end

  def since(date)
    date = Time.parse date.to_s

    # TODO: Merge orders with the reported orders. We need to remove duplicates.
    # ox = report_orders.collect do |order|
    #   last_modified = Time.parse order.fetch('LastModified')
    #   get_order order.fetch('OrderID') if last_modified >= date
    # end.compact

    orders date
  end

  def format
    CDON::V1::OrderFormatter.new(self).format
  end

  private

    def orders(date)
      response = connection.get("api/order") do |r|
        r.params[:since] = date.to_s(:db)
        r.params[:CountryCode] = country
      end

      if response.success?
        JSON.parse response.body
      else
        []
      end
    end

    def report_orders
      @report ||= begin
        params = {
          ReportId: config.fetch('report_id'),
          format: 'json',
          filter: {
            CountryCodes: [country],
            PaymentStates: ['2'],
          }.to_json,
        }
        Arctic.logger.info "Getting report with params: #{params}"

        # PaymentState '2' means State - 'Paid'
        response = connection.post("api/reports") do |req|
          req.body = params.to_query
        end

        if response.success?
          JSON.parse(response.body).fetch('Orders')
        else
          []
        end
      end
    end

    def connection
      @connection ||= Faraday.new(connection_options) do |f|
        f.request :curl, Arctic.logger, :info
        f.adapter Faraday.default_adapter
      end
    end

    def connection_options
      {
        url: url,
        headers: {
          'Authorization': "api #{api_key}",
        },
      }
    end

    def api_key
      @api_key ||= shop.fetch('auth_config').fetch('api_key')
    end

    def config
      shop.fetch 'config'
    end

    def url
      ENV.fetch('MARKETPLACE_URL', 'https://integration-admin.marketplace.cdon.com')
    end

    def get_order(id)
      response = connection.get("api/order/#{id}")
      if response.success?
        JSON.parse(response.body)
      else
        []
      end
    end

    def country
      @country ||= CDON::Country.to_name config.fetch('country')
    end
end
