# frozen_string_literal: true

class Smartweb::V1::Formatters::FormatProduct
  attr_reader :product, :shop, :variant, :image_url

  def initialize(product, shop, image_url, variant=nil)
    @product             = product
    @shop                = shop
    @variant             = variant
    @image_url           = image_url
  end

  def format
    {
      name: product.fetch(:title),
      brand: producer_name,
      manufacturer: producer_name,
      sku: product.fetch(:item_number),
      ean: product.fetch(:ean),
      description: description,
      original_price: original_price(product),
      offer_price: discount_price(product),
      stock_count: product.fetch(:stock),
      weight: get_weight(product),
      categories: categories,
      images: product_picture_urls,
      raw_data: product,
      master_id: nil
    }
  end

  def format_variant
    data = \
      {
        name: variant.fetch(:title),
        brand: producer_name,
        manufacturer: producer_name,
        sku: variant.fetch(:item_number),
        ean: variant.fetch(:ean),
        description: description,
        original_price: original_price(variant),
        offer_price: discount_price(variant),
        stock_count: variant.fetch(:stock),
        weight: get_weight(variant),
        categories: categories,
        images: variant_picture_urls(variant),
        raw_data: variant,
        master_id: product.fetch(:item_number)
      }

    parse_custom_data(data)

    data
  end

  def parse_custom_data(data)
    shop.fetch('product_parse_config').each do |import_map|
      variant_type_names    = import_map['from'].split(', ')

      product_variant_types = product[:variant_types].split('//')

      variant_type_names.each do |variant_type_name|
        next unless product_variant_types.include? variant_type_name

        [variant.dig(:variant_type_values, :item)].flatten(1).compact.each do |variant_type_value_id|
          variant_type_value = api.get_variant_type_value(variant_type_value_id)

          variant_type       = api.get_variant_type(variant_type_value[:product_variant_type_id])

          data[import_map['to'].to_sym] = variant_type_value[:title] if variant_type[:title] == variant_type_name
        end
      end
    end
  end

  def producer_name
    if product.dig(:producer, :lastname) && product.dig(:producer, :firstname)
      "#{product.dig(:producer, :firstname)} #{product.dig(:producer, :lastname)}"
    elsif product.dig(:producer, :firstname)
      product.dig(:producer, :firstname)
    elsif product.dig(:producer, :lastname)
      product.dig(:producer, :lastname)
    else
      nil
    end
  end

  def get_weight(item)
    weight = item.fetch(:weight)
    weight.present? ? (weight.to_f * 1000) : nil
  end

  def base_currency_iso
    config.fetch('base_currency')
  end

  def currency_iso
    config.fetch('currency')
  end

  def currency_rate
    currency_obj = api.get_currency(currency_iso)
    currency_obj.fetch(:currency)
  end

  def original_price(product)
    if discount.present?
      price = (discount[:price].to_f * 100).round
    else
      if base_currency_iso == currency_iso
        price = (product[:price].to_f * 100).round
      else
        price = (product[:price].to_f * 100 / currency_rate.to_f).round
      end
    end

    { cents: price, currency: currency_iso }
  end

  def discount_price(product)
    price = \
      if discount.present?
        calculate_discount(price: discount[:price], discount: discount[:discount],
                                  discount_type: discount[:discount_type])
      else
        base_currency_value = calculate_discount(price: product[:price], discount: product[:discount],
                                                 discount_type: product[:discount_type])

        base_currency_iso == currency_iso ? base_currency_value : (base_currency_value / currency_rate.to_f).round
      end

    { cents: price, currency: currency_iso }
  end

  def discount
    @discount ||= variant.present? ? (variant_discount || product_discount) : product_discount
  end

  #
  # SmartWeb way of storing different prices is storing them inside *Discount* objects
  #
  def discounts
    @discounts ||= [product.dig(:discounts, :item)].flatten(1).compact
  end

  def product_discount
    @product_discount ||= \
      discounts.find_all do |discount|
        # product_variant_id that equals '0' means that discount is not for variant
        discount[:currency] == currency_iso && discount[:amount] == '1' && discount[:product_variant_id] == '0'
      end.last
  end

  def variant_discount
    @variant_discount ||= \
      discounts.find_all do |discount|
        discount[:currency] == currency_iso && discount[:amount] == '1' && discount[:product_variant_id] == variant[:id]
      end.last
  end

  #
  # Here we are calculating mathematical discount, not the SmartWeb object *Discount*
  #
  def calculate_discount(price:, discount:, discount_type:)
    if discount_type == 'a'
      ((price.to_f - discount.to_f) * 100).round
    elsif discount_type == 'p'
      ((price.to_f / 100 * (100 - discount.to_f)) * 100).round
    else
      raise "Unknown price discount type: #{discount_type}"
    end
  end

  def product_picture_urls
    product_pictures.map { |picture| combine_image_url(picture[:file_name]) }
  end

  def variant_picture_urls(variant)
    variant_picture_ids = [variant.dig(:picture_ids, :item)].flatten(1).compact

    if variant_picture_ids.blank?
      picture = product_pictures.find { |product_picture| product_picture[:sorting] == '1' }

      picture.present? ? [combine_image_url(picture[:file_name])] : []
    else
      variant_picture_ids.map do |variant_picture_id|
        picture = product_pictures.find { |product_picture| product_picture[:id] == variant_picture_id }
        combine_image_url(picture[:file_name]) if picture.present?
      end.compact
    end
  end

  def product_pictures
    [product.dig(:pictures, :item)].flatten(1).compact
  end

  def combine_image_url(file_name)
    "#{image_url}/#{file_name}"
  end

  def categories
    [product[:category_id]] + secondary_category_ids
  end

  def secondary_category_ids
    [product.dig(:secondary_category_ids, :item)].flatten(1).compact
  end

  def description
    product[:description_long].presence || product[:description].presence || product[:description_short].presence
  end

  private

    def core
      @core ||= Arctic::Vendor::Collection::API.new
    end

    def config
      @config ||= shop.fetch('config').as_json
    end

    def api
      @api ||= Smartweb::V1::API.new(shop)
    end
end
