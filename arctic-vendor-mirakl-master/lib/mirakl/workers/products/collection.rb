# frozen_string_literal: true

class Mirakl::Workers::Products::Collection < Mirakl::Workers::Base
  PRODUCTS_PER_FEED = ENV['PRODUCTS_PER_FEED']&.to_i || 2_500
  FEED_TYPE         = 'ProductsAndOffers'

  sidekiq_options \
    queue: :products_dispersal

  def perform(shop_id)
    @shop_id = shop_id

    return unless products.present?

    process_xml(products_xml)

    update_states(:completed)

    self.class.perform_in(10.minutes, shop_id) if products.size >= PRODUCTS_PER_FEED
  end

  private

  def products
    @products ||= core_api.list_products shop_id, PRODUCTS_PER_FEED, feed_type: FEED_TYPE
  end

  def products_xml
    @products_xml ||= Mirakl::XML::Builder.new(products, mirakl_api).to_xml
  end

  def process_xml(xml)
    filename = Mirakl::Services::Archive.archive_xml(xml, shop_id)

    import_create_response = mirakl_api.create_import(filename)

    process_errors(import_create_response)
  rescue
    update_states(:pending)
  end

  def process_errors(import_create_response)
    sleep 5.seconds # wait for response to be processed

    import = mirakl_api.get_import(import_create_response['import_id'])

    return unless import['has_transformation_error_report']

    error_report = mirakl_api.get_error_report(import_create_response['import_id'])

    reported_products = [error_report.dig('root', 'product')].flatten(1).compact

    reported_products.each do |product|
      sku = product['attribute'].find { |attr| attr['code'] == 'Shop_SKU' }['value']

      errors = product['errors'].split(',')

      errors.each do |error|
        code, message = error.split('|')

        core_api.report_error shop_id, sku, error_code: code, message: message, feed_type: FEED_TYPE
      end

      core_api.update_products_dispersals shop_id, product_skus: [sku], state: :failed, feed_type: FEED_TYPE,
                                          synchronous: true
    end
  end

  def update_states state
    products.each_slice(1_000) do |slice|
      product_skus = slice.map { |product| product['sku'] }

      core_api.update_products_dispersals shop_id, product_skus: product_skus, state: state, feed_type: FEED_TYPE,
                                          synchronous: true
    end
  end
end