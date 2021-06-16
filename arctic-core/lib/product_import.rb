# frozen_string_literal: true

require 'csv'

class ProductImport
  attr_reader :path, :shop, :updated_products, :vendor, :failed

  def initialize(vendor, shop, path)
    @path = path
    @shop = shop
    @vendor = vendor
    @updated_products = []
    @failed = false
  end

  def save
    update_products
    clear_product_caches
    success?
  end

  private

    def clear_product_caches
      updated_products.each do |product|
        ProductCache.write product
      end
    end

    def update_products
      Product.transaction do
        ::CSV.foreach(path, headers: true, col_sep: ';').each do |row|
          update_product row
        end
      end
    end

    def success?
      !failed
    end

    def update_product(csv_row)
      shadow = shadow_from_sku csv_row['sku']
      update_shadow_product shadow, csv_row
      updated_products << shadow.product
    rescue ActiveRecord::RecordNotFound => e
      @failed = true
      Rails.logger.info "Rolling back ProductImport because (#{e.class}): #{e.message}"
      raise ActiveRecord::Rollback
    end

    def shadow_from_sku(sku)
      product = shop.products.find sku
      product.shadow_product vendor
    end

    def changed_characteristics(shadow, csv_row)
      atrs = csv_row.to_h.slice(*Product::CHARACTERISTICS)

      prod = ProductMerger.new(shadow.product, vendor: vendor).result
      matrs = prod.attributes.slice(*Product::CHARACTERISTICS)

      atrs.reject { |k, v| matrs[k] == v }
    end

    def update_shadow_product(shadow, csv_row)
      new_atrs = changed_characteristics(shadow, csv_row)
      Rails.logger.info "Changes for #{shadow.id}: #{new_atrs}"
      shadow.update new_atrs
      update_prices shadow, csv_row
    end

    def update_prices(shadow, csv_row)
      original_price = ProductPrice.create \
        cents: csv_row['original_price'].to_f * 100.0,
        currency: csv_row['original_currency']

      offer_price = ProductPrice.create \
        cents: csv_row['offer_price'].to_f * 100.0,
        currency: csv_row['offer_currency'],
        expires_at: csv_row['offer_expires_at']

      shadow.update \
        original_price: original_price,
        offer_price: offer_price
    end
end
