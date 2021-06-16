# frozen_string_literal: true

require 'csv'

class ProductExport
  attr_reader :vendor, :shop, :url

  def initialize(vendor, shop)
    @vendor = vendor
    @shop = shop
  end

  def generate
    generate_csv
    @url = upload_to_s3
  ensure
    FileUtils.rm file if File.exist? file
  end

  def file
    @file ||= Rails.root.join('tmp', 'exports', filename).tap do |f|
      FileUtils.mkdir_p File.dirname(f)
    end
  end

  private

    def upload_to_s3
      S3Uploader
        .new(bucket)
        .upload(file, **write_options)
        .url_for(file, **url_options)
        .tap do |url|
        Rails.logger.info "ProductExport uploaded (#{file}) to: #{url}"
      end
    end

    def write_options
      {
        metadata: {
          generated: Time.zone.now.httpdate,
        },
        content_type: 'text/csv',
      }
    end

    def url_options
      {
        expires_in: 48.hours.to_i,
      }
    end

    def generate_csv
      CSV.open(file, 'wb', encoding: 'UTF-8', col_sep: ';') do |csv|
        csv << export_fields

        shop.products.find_each do |product|
          generate_product_row csv, product
        end
      end

      Rails.logger.info "ProductExport generated #{file}"
    end

    def generate_product_row(csv, product)
      merged_product = ProductMerger.new(product, vendor: vendor).result

      return if merged_product.deleted_at

      atrs = merged_product.attributes.slice(*export_fields)
      export_original_price merged_product, atrs
      export_offer_price merged_product, atrs
      csv << atrs.values
    end

    def bucket
      @bucket ||= "arctic-core-api-product-exports-#{Rails.env}"
    end

    def filename
      @filename ||= [
        S3Uploader.sanitize(shop.name),
        S3Uploader.sanitize(vendor.name),
        "#{Time.zone.now.to_i}.csv",
      ].compact.join('-')
    end

    def export_fields
      [
        Product::CHARACTERISTICS,
        :original_currency,
        :original_price,
        :offer_currency,
        :offer_price,
      ].flatten
    end

    def export_original_price(product, atrs)
      exchange = ProductPriceExchange.new product.original_price, shop: shop, vendor: vendor
      atrs[:original_currency] = exchange.price.currency.iso_code
      atrs[:original_price] = exchange.price.cents.to_f / 100.0
    rescue ProductPriceExchange::MissingPrice
      nil
    end

    def export_offer_price(product, atrs)
      exchange = ProductPriceExchange.new product.offer_price, shop: shop, vendor: vendor
      atrs[:offer_currency] = exchange.price.currency.iso_code
      atrs[:offer_price] = exchange.price.cents.to_f / 100.0
    rescue ProductPriceExchange::MissingPrice
      nil
    end
end
