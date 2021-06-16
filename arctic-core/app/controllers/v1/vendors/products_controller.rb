# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/ClassLength

require 'sku'

class V1::Vendors::ProductsController < V1::Vendors::ApplicationController #:nodoc:
  # Create product that has been collected in vendor
  def create
    sku = Sku.new(product_params['sku']).to_s
    product = shop.products.with_deleted.find_by sku: sku
    product = Product.new(shop: shop, sku: sku) unless product.present?
    product.original_sku = product_params['sku']

    status = product.persisted? ? 200 : 201

    # Remove the product
    if params[:remove]
      product.destroy if product.persisted?
      head :no_content
      return
    end

    update_product_prices product
    update_product_characteristics product

    # Workers
    V1::Vendors::ShadowProductWorker.perform_async product.id
    V1::Vendors::ChannelProductMatchWorker.perform_async shop.id, product.id

    if status == 201
      V1::WebhookWorker.perform_async vendor_shop_configuration.id,
        :product_created,
        product.id
    else
      V1::WebhookWorker.perform_async vendor_shop_configuration.id,
        :product_updated,
        product.id,
        product.most_recent_changes.except('updated_at')
    end

    render \
      status: status,
      json: V1::Vendors::ProductBlueprint.render(product)
  end

  def update
    dispersals = product.dispersals.incomplete
    Rails.logger.info dispersals.explain

    dispersal = dispersals.find_or_initialize_by vendor_shop_configuration: vendor_shop_configuration
    dispersal.state = valid_state
    dispersal.save!

    ProductCache.write product
    render json: V1::Vendors::ProductBlueprint.render(product)
  end

  def last_synced_at
    render json: { last_synced_at: vendor_shop_configuration.last_synced_at.try(:httpdate) }
  end

  def index
    # Subquery to calculate if the product hasn't been dispersed yet
    no_dispersals = <<-SQL
      0 = (
        select count(dispersals.*)
        from dispersals
        where dispersals.deleted_at is null and
              dispersals.product_id = shadow_products.product_id and
              dispersals.vendor_shop_configuration_id = shadow_products.vendor_shop_configuration_id
      )
    SQL

    # Subquery to calculate if the product is available for dispersal
    available_for_dispersal = <<-SQL
      0 = (
        select count(dispersals.*)
        from dispersals
        where dispersals.deleted_at is null and
              dispersals.product_id = shadow_products.product_id and
              dispersals.state in ('inprogress', 'failed') and
              dispersals.vendor_shop_configuration_id = shadow_products.vendor_shop_configuration_id
      )
    SQL

    # Subquery to calculate if the product has been matched with the vendor
    # validation
    matched_with_vendor = <<-SQL
      (
        select count(*)
        from vendor_product_matches
        where vendor_product_matches.product_id = shadow_products.product_id and
              vendor_product_matches.vendor_shop_configuration_id = shadow_products.vendor_shop_configuration_id and
              vendor_product_matches.matched = true
      ) > 0
    SQL

    updated_sql = <<-SQL
      shadow_products.updated_at > :date or
      products.updated_at > :date or
      ('#{config.last_synced_at}' = '') is true
    SQL

    shadow_products = current_vendor
      .shadow_products
      .joins(:product)
      .where(product: shop.products)
      .where(matched_with_vendor)
      .where(updated_sql, date: vendor_shop_configuration.last_synced_at)
      .where("#{available_for_dispersal} or #{no_dispersals}")
      .order('shadow_products.product_id asc')

    skus = params[:skus].to_s.split(',')

    if skus.any?
      skus_sql = <<-SQL
        shadow_products.sku in (?) or
        shadow_products.master_sku in (?) or
        products.sku in (?) or
        products.master_id in (?)
      SQL
      shadow_products = shadow_products.where(skus_sql, skus, skus, skus, skus)
    end

    shadow_products = shadow_products.where(enabled: true)

    Rails.logger.info shadow_products.explain

    shadow_products = paginate shadow_products

    merged_products = shadow_products.collect do |shadow_product|
      ProductMerger.new(shadow_product.product, vendor: current_vendor).result
    end

    options = {
      vendor: current_vendor,
      shop: shop,
    }
    options[:fields] = params[:fields].split(',') if params[:fields].present?

    render json: V1::Vendors::ProductBlueprint.render(merged_products, options)
  end

  def update_scheduled
    products = shop.products.where(update_scheduled: true)
    render json: V1::Vendors::UpdateScheduledBlueprint.render(products)
  end

  private

    def shop
      @shop ||= current_vendor.shops.find params[:shop_id]
    end

    def vendor_shop_configuration
      @vendor_shop_configuration ||= shop.vendor_config_for current_vendor
    end

    def merge_product_information(products)
      products.collect do |product|
        ProductMerger.new(product, vendor: current_vendor).result
      end
    end

    def product_params
      params.permit(*Product::CHARACTERISTICS, categories: [])
    end

    def product
      @product ||= current_vendor.dispersal_shops
                       .find(params[:shop_id])
                       .products
                       .find_by_sku(params[:id])
    end

    def valid_state
      (Dispersal::STATES & [params[:state].to_s]).first || :pending
    end

    def update_product_characteristics(product)
      # Restore product if deleted
      product.restore if product.deleted?

      product.stock_count = params.fetch(:stock_count, 0)

      # Update product attributes
      product.attributes = product_params.except('sku')

      set_master_product(product) if product_params[:master_id]

      # Scheduled flag set back to false on update process
      product.update_scheduled = false

      # Save the product if it changed
      product.save! if product.changed?

      # Reset counter cache
      Product.reset_counters(product.id, :variants)

      # Attach raw product data
      # product.raw_product_data.create data: params.fetch(:raw_data)

      # Attach images
      params.fetch(:images, []).each do |url|
        product.images.find_or_create_by url: url
      end
    end

    def set_master_product(product)
      master = Product.find_by_sku(product_params[:master_id])
      product.master_id = master.id if master
    end

    def original_price_params
      params
        .require(:original_price)
        .permit(:cents, :currency, :expires_at)
    rescue ActionController::ParameterMissing
      nil
    end

    def offer_price_params
      params
        .require(:offer_price)
        .permit(:cents, :currency, :expires_at)
    rescue ActionController::ParameterMissing
      nil
    end

    def update_product_prices(product)
      product.original_price.try :destroy
      original_price = ProductPrice.create original_price_params
      product.original_price = original_price if original_price.persisted?

      product.offer_price.try :destroy
      offer_price = ProductPrice.create offer_price_params
      product.offer_price = offer_price if offer_price.persisted?
    end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/ClassLength
