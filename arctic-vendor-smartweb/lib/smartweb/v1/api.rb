# frozen_string_literal: true

class Smartweb::V1::API
  Error = Class.new StandardError

  class InvalidResponse < Error
    def initialize(response)
      status = response.http_error
      message = 'Response from Smart web was not successful'
      msg = "#{message} / #{status}"
      super(msg)
    end
  end

  ORDERS_COLLECT_DAYS = 1

  attr_reader :client, :shop

  def initialize(shop)
    @shop   = shop.as_json
    @client = Savon.client(wsdl: config.fetch('wsdl_url'))
    solution_connect
    set_products_fields
  end

  def config
    @config ||= shop.fetch('config').as_json
  end

  def auth_config
    @auth_config ||= shop.fetch('auth_config').as_json
  end

  def solution_connect
    response = client.call(:solution_connect, message: {
      'Username' => auth_config.fetch('username'),
      'Password' => auth_config.fetch('password')
    })

    # set 'headers cookies' to be able to make authorized requests
    client.globals[:headers] = { 'Cookie' => response.http.headers['Set-Cookie'] }

    # set the localization
    locale = config.fetch('locale')
    client.call(:solution_set_language, message: { 'LanguageISO' => locale }) if locale.present?
  end

  def set_products_fields
    client.call(:product_set_fields, message: {
      'Fields' => 'Id,ItemNumber,CategoryId,SecondaryCategoryIds,Producer,Description,DescriptionLong,' \
                  'DescriptionShort,Ean,Price,Pictures,Title,' \
                  'Weight,Variants,Stock,Unit,Discount,DiscountType,Discounts,DisableOnEmpty,VariantTypes'
    })
    client.call(:product_set_variant_fields, message: {
      'Fields' => 'Id,ProductId,ItemNumber,Ean,Price,Title,Discount,DiscountType,Weight,Stock,Unit,PictureIds,' \
                  'DisableOnEmpty,VariantTypeValues'
    })
    client.call(:user_set_fields, message: {
      'Fields' => 'Id,Firstname,Lastname'
    })
  end

  def orders
    client.call(:order_set_fields, message: { 'Fields' => 'TrackingCode,ReferenceNumber' })

    start_from = ORDERS_COLLECT_DAYS.days.ago.strftime('%Y-%m-%d')

    response = make_request(:order_get_by_date_updated, 'Start' => start_from)

    response = response.dig(:order_get_by_date_updated_response, :order_get_by_date_updated_result, :item)

    [response].flatten(1).compact
  end

  def products(start_date_string, end_date_string=nil)
    result_products = []
    url             = config.fetch('image_url')

    start_date = start_date_string.present? ? Date.parse(start_date_string) : nil
    end_date = end_date_string.present? ? Date.parse(end_date_string) : nil

    proper_start_date = start_date.present? ? start_date.strftime('%Y-%m-%d %H:%M:%S') : nil
    proper_end_date = end_date.present? ? end_date.strftime('%Y-%m-%d %H:%M:%S') : nil

    # TODO previous request was :product_get_all and was much faster need to compare
    response = make_request(:product_get_by_updated_date,
                            { 'Start' => proper_start_date, 'End' => proper_end_date })

    products = \
      [response.dig(:product_get_by_updated_date_response, :product_get_by_updated_date_result, :item)]
      .flatten(1).compact

    products.each_slice(1_000) do |slice|
      slice.each do |product|
        next unless product[:item_number].present?
        next unless product[:title].present?

        product_hash = format(product, shop, url)

        result_products << product_hash

        variants = [product.dig(:variants, :item)].flatten(1).compact

        variants.each do |variant|
          next unless variant[:item_number].present?
          next unless variant[:title].present?

          formatted_variant = format_variant(product, shop, url, variant)
          result_products   << formatted_variant
        end
      end
    end

    result_products
  end

  def categories
    response = make_request(:category_get_all)
    categories = response.dig(:category_get_all_response, :category_get_all_result, :item)
    result_categories = []

    categories.each_slice(1_000) do |slice|
      slice.each do |category|
        category_hash = format_category(category)
        result_categories << category_hash
      end
    end

    result_categories
  end

  def create_order(order)
    make_request(:order_create, { 'OrderData' => order })
  end

  def update_order_status(order_id, status)
    make_request(:order_update_status, { 'OrderId' => order_id, 'Status' => status })
  end

  def get_currency(currency)
    response = make_request(:currency_get_by_iso, { 'Iso' => currency })
    response.dig(:currency_get_by_iso_response, :currency_get_by_iso_result)
  end

  def get_product(sku)
    response = make_request(:product_get_by_item_number, { 'ItemNumber' => sku })
    response.dig(:product_get_by_item_number_response, :product_get_by_item_number_result, :item)
  end

  def get_variant_type(id)
    response = make_request(:product_get_variant_type, { 'VariantTypeId' => id })

    response.dig(:product_get_variant_type_response, :product_get_variant_type_result)
  end

  def get_variant_type_value(id)
    response = make_request(:product_get_variant_type_value, { 'TypeValueId' => id })

    response.dig(:product_get_variant_type_value_response, :product_get_variant_type_value_result)
  end

  private
    def format(product, shop, url)
      Smartweb::V1::Formatters::FormatProduct.new(product, shop, url).format
    end

    def format_variant(product, shop, url, variant)
      Smartweb::V1::Formatters::FormatProduct.new(product, shop, url, variant).format_variant
    end

    def format_category(category)
      Smartweb::V1::Formatters::FormatCategory.new(category).format
    end

    def make_request(method, options={})
      Arctic.logger.info("#{method.to_s.upcase}: requested")

      begin
        response = client.call(method, message: options)

        response.body
      rescue => e
        Arctic.logger.error "Failed to call :#{method} details: #{e.message}"
      end
    end
end
