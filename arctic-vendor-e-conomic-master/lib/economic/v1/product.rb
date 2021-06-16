class Economic::V1::Product
  ESCAPE_CHARS = {'$' => '$$', '(' => '$(', ')' => '$)', '*' => '$*', ',' => '$,', '[' => '$[', ']' => '$]'}

  attr_reader :shop, :original_product_id, :name

  def initialize(shop:, product_id:, name:)
    @shop                = shop
    @original_product_id = product_id
    @name                = name
  end

  def find_or_create!
    find! || create!
  end

  private

  def find!
    api.find_product(product_id: encoded_product_id, product_group_number: config.fetch('productGroupNumber'))
  end

  def create!
    api.create_product(product_data)
  end

  def product_id
    return @product_id if defined? @product_id

    id = original_product_id.dup

    config['skuPrefix'].present? ? id.prepend(config.fetch('skuPrefix')) : id

    @product_id = id[0..24]
  end

  def encoded_product_id
    return @encoded_product_id if defined? @encoded_product_id

    id = product_id.dup

    ESCAPE_CHARS.each { |k, v| id.gsub!(k, v) }

    @encoded_product_id = id
  end

  def product_data
    @product_data ||= \
      {
        productNumber: product_id,
        name: name,
        productGroup: {
          productGroupNumber: config.fetch('productGroupNumber').to_i
        }
      }
  end

  def config
    @config ||= shop.fetch 'config'
  end

  def api
    @api ||= Economic::V1::API.new shop
  end
end
