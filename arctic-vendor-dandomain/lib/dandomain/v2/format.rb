require 'active_support/core_ext/module/delegation'

class String
  def number?
    to_s.to_i.to_s == to_s
  end
end

class Dandomain::V2::Format
  attr_reader :shop, :product

  def initialize(shop, product)
    @shop = shop.as_json
    @product = product.as_json
  end

  def as_json
    format product
  end

  private

    def format(product)
      Arctic.logger.info "Formatting #{product['productNumber']}"
      data = {
        sku: product.fetch('productNumber'),
        original_price: original_price(product),
        offer_price: offer_price(product),
        categories: categories(product),
        images: images(product),
        raw_data: product,
        master_id: product.fetch('variantMasterNumber'),
      }

      data.merge! characteristics(product)

      data.merge! parse_custom_data(product, data)

      data
    rescue => e
      id = product.fetch('productNumber')
      Arctic.logger.warn "Failed to format Product(#{id}) (#{e.class}): #{e.message}"
      Arctic.logger.debug "Failed to format product: #{product}"
      nil
    end

    def characteristics(product)
      data = {
        ean: product.fetch('barcode', nil),
        name: product.fetch('name'),
        stock_count: product.fetch('stockCount'),
        remove: product.fetch('isHidden', false),
      }

      # Manufacturer and brand
      manufacturer = product.fetch('manufacturers', []).first
      data['brand'] = data['manufacturer'] = manufacturer['name'] if manufacturer

      # Extract description from multiple places
      # Fallback to product name as it's description
      #
      fetch_description = product.fetch('description', nil)
      description = fetch_description['description'] if fetch_description

      data['description'] ||= \
        description ||
        product.fetch('shortDescription', nil) ||
        data['name']

      data
    end

    def categories(product)
      product.fetch('categories', {}).fetch('items', []).compact.collect do |cat|
        cat.fetch('id')
      end
    end

    def price(product)
      b2bid = shop.fetch('config', {}).fetch 'b2b_group_id', '-2' # b2c - http://bit.ly/2QAnyKR

      b2bid_match = product
        .fetch('prices', {})
        .fetch('items', [])
        .detect { |i| i['b2BGroupId'] == b2bid }

      return b2bid_match if b2bid_match

      product
        .fetch('prices', {})
        .fetch('items', [])
        .first
    end

    def offer_price(product)
      pr = price product
      {
        cents: pr['specialOfferIncVAT'].to_f * 100,
        currency: pr['currencyCode'],
        expires_at: pr['endDate'],
      }
    end

    def original_price(product)
      pr = price product

      {
        cents: pr['incVAT'].to_f * 100,
        currency: pr['currencyCode'],
      }
    end

    def images(product)
      host = shop.fetch('config').fetch('host')

      imgs = product.fetch('media', {}).fetch('items', []).compact.collect do |image|
        thumbnail = URI.escape image.fetch('thumbnail')
        get_size(thumbnail, host) || thumbnail
      end

      # Default image lives on the main product, not in the media section
      # we try to get -p version if available
      main_image = product.fetch('image')
      main_image_big_path = main_image.gsub('.', '-p.')
      main_image_path = if faraday_success?(host, main_image_big_path)
                          main_image_big_path
                        else
                          main_image
                        end
      imgs << main_image_path
      imgs.collect { |path| "#{host}#{path}" }
    end

    def get_size(thumbnail, host)
      %w( -p. -o. .).each do |size|
        my_size = thumbnail.gsub('-t.', size)
        return my_size if faraday_success?(host, my_size)
      end
      nil
    end

    def faraday_success?(host, path)
      uri = "#{host}#{path}"
      correct_uri = (URI.unescape(uri).length < uri.length) ? uri : URI.escape(uri)
      Faraday.get(correct_uri).success?
    rescue => e
      Arctic.logger.warn "Failed URI (#{e.class}): #{e.message}"
      false
    end

    # This uses the product_parse_config field from the shop to extract
    # further information about the product from uncommon or unexpected
    # fields in the raw JSON.
    def parse_custom_data(product, orig_data)
      data = {}

      orig_data.deep_stringify_keys!

      shop.fetch('product_parse_config').each do |import_map|
        raw_value = product.dig(*import_map['from'].split('.')).presence

        unless raw_value
          begin
            groups = product
              .fetch('variantgroups', {})
              .fetch('items', [])
              .detect do |v|
                text = v['text'].to_s.downcase
                text == import_map['from'].to_s.downcase
              end

            variant_groups = Hash[
              groups
                .fetch('variants', {})
                .fetch('items', [])
                .collect { |g| [g['id'], g['text']] }
            ]

            variations = product
              .fetch('variants', {})
              .fetch('items', [])
              .collect { |v| v['id'] }

            matching_variant = (variant_groups.keys & variations).first

            raw_value = variant_groups[matching_variant]
          rescue NoMethodError
            Arctic.logger.warn "Unable to find varant data matching ImportMap #{import_map}"
          end
        end

        if import_map['regex']
          parsed_value = raw_value.to_s.scan(Regexp.new(import_map['regex'])).flatten.first
        else
          parsed_value = raw_value
        end

        data[import_map['to']] = parsed_value if parsed_value
      end

      data
    end
end
