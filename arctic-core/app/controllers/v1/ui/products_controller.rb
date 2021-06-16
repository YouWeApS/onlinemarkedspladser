# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/ClassLength

require 'csv'

class V1::Ui::ProductsController < V1::Ui::ApplicationController #:nodoc:
  ERRONEOUS = 'erroneous'
  DISPERSED = 'dispersed'
  DISABLED = 'disabled'
  ENABLED = 'enabled'
  PER_PAGE = 20

  def index
    doorkeeper_authorize! 'product:read'
    render json: V1::Ui::ProductListBlueprint.render(products_list, vendor: current_vendor.id) if render_index?
  end

  def destroy
    doorkeeper_authorize! 'product:write'
    shadow_product.destroy
    ProductCache.write shadow_product
    render json: show_json, status: :no_content
  end

  def export
    doorkeeper_authorize! 'product:read'

    V1::Ui::ProductExportWorker.perform_async \
      current_user.id,
      current_vendor.id,
      current_shop.id

    render json: {}, status: :accepted
  end

  def import
    doorkeeper_authorize! 'product:write'

    filename = [
      S3Uploader.sanitize(current_shop.name),
      S3Uploader.sanitize(current_vendor.name),
      Time.zone.now.to_i,
    ].join('-')

    path = Rails.root.join 'tmp', 'imports', "#{filename}.csv"

    FileUtils.mkdir_p File.dirname path

    file_content = params[:file]
      .read
      .force_encoding('ASCII-8BIT')
      .encode('UTF-8', undef: :replace, replace: '')

    File.open(path, 'w') { |f| f.write file_content }

    # Enqueue file processing
    V1::Ui::ProductImportWorker.perform_async \
      current_user.id,
      current_vendor.id,
      current_shop.id,
      path

    render json: {}, status: :accepted
  end

  def update
    doorkeeper_authorize! 'product:write'

    if !params[:enabled].nil? && shadow_product.enabled != params[:enabled]
      enable_product
    else

      shadow_product.restore if shadow_product.deleted?

      shadow_product.update shadow_product_params.merge \
        original_price: original_price,
        offer_price: offer_price,
        platinum_keywords: platinum_keywords,
        key_features: key_features

      set_product_pending
      update_product_required
      update_shadow_product_master_sku

      ProductCache.write shadow_product

      V1::Ui::ProductCacheWorker.perform_async shadow_product.product.sku

      V1::WebhookWorker.perform_async \
        current_vendor_config.id,
        :shadow_product_updated,
        shadow_product.id,
        shadow_product.most_recent_changes.except('updated_at')

      V1::Vendors::ChannelProductMatchWorker.perform_async \
        shadow_product.product.shop_id,
        shadow_product.product_id
    end

    render json: show_json
  end

  # Deliver the raw product data last delivered for the product filtered through
  # the configured product import settings.
  #
  # TODO: This code is duplicated in the Dandomain project also. Consider
  #       extracting this into a product import parsing gem to deduplicate this
  #       code.
  def raw
    doorkeeper_authorize! 'product:read'
    params[:id] ||= shadow_products.without_deleted.first.id

    data = {}

    render json: data
  end

  def disperse
    SynchronizationProcess.new(current_vendor, current_shop).send
    render json: {}
  end

  def enable
    V1::UI::EnableShadowProductsWorker.perform_async(params[:products], params[:enabled])

    render json: {}
  end

  def show
    doorkeeper_authorize! 'product:read'

    render json: show_json if render_show?
  end

  private

    def enable_product
      shadow_product.update_attribute(:enabled, params[:enabled])

      if shadow_product.master?
        shadow_product.product.variants.each do |product|
          product.shadow_product(current_vendor).update_attribute(:enabled, params[:enabled])
        end
      end
    end

    def products_list
      config = current_shop.vendor_config_for current_vendor

      @products_list ||= begin
        sx = ShadowProduct
          .joins(:product)
          .where(products: { shop: current_shop })
          .where(vendor_shop_configuration: config)

        sx = filter_selection(sx)
        sx = disabled_filter(sx)

        sx = sx.order 'products.sku ASC'

        per_page = filter_params[:per_page] || 20

        sx = paginate sx, per_page: per_page

        Rails.logger.info sx.explain

        sx
      end
    rescue Pagy::OutOfRangeError
      params[:page] = 1
      retry
    end

    def filter_selection(products)
      products = products.where('products.master_id is null') if filter_params[:master]
      products = (filter_params[:removed].to_boolean ?
                      products.only_deleted : products.with_deleted) if !filter_params[:removed].nil?

      if filter_params[:search]
        sql = <<-SQL
            lower(shadow_products.sku) ~ :search or
            lower(shadow_products.ean) ~ :search or
            lower(shadow_products.description) ~ :search or
            lower(shadow_products.name) ~ :search or

            lower(products.sku) ~ :search or
            lower(products.ean) ~ :search or
            lower(products.description) ~ :search or
            lower(products.name) ~ :search
        SQL
        products = products.where(sql, search: filter_params[:search].to_s.downcase)
      end

      products = state_filter(products)
      if params[:master_id]
        childs = products.where(master_id: params[:master_id])
        products = childs.empty? ? products.where('products.master_id = ?', params[:master_id]) : childs
      end

      products
    end

    def state_filter(products)
      if filter_params[:state] == DISPERSED
        products = products.includes(:dispersals).where(dispersals: { state: :completed })
      elsif filter_params[:state] == ERRONEOUS
        config = current_shop.vendor_config_for current_vendor
        union_products = products.includes(:failed_vendor_product_matches).includes(:product_errors)
        products = union_products
          .where(vendor_product_matches: { vendor_shop_configuration: config })
          .or(union_products.where('product_errors.severity in (:errors)', errors: %w[error warning]))
      end
      products
    end

    def disabled_filter(products)
      if filter_params[:disabled] == DISABLED
        products =  products.disabled_products
      elsif filter_params[:disabled] == ENABLED
        products =  products.enabled_products
      end
      products
    end

    def render_show?
      last_modified = [
        shadow_product.product.updated_at,
        shadow_product.product.deleted_at,
        shadow_product.updated_at,
        shadow_product.deleted_at,
        shadow_product.product_id.try(:master).try(:updated_at),
        shadow_product.product_id.try(:master).try(:deleted_at),
      ].compact.max

      stale? etag: shadow_product, last_modified: last_modified
    end

    def shadow_product_params
      params.permit(*Product::CHARACTERISTICS, categories: []).merge specific_fields
    end

    def specific_fields
      params.permit \
       :legal_disclaimer,
       :search_terms
    end

    def shadow_product
      @shadow_product ||= shadow_products
        .with_deleted
        .where(id: params[:id])
        .take!
    end

    def shadow_products
      @shadow_products ||= current_vendor.shadow_products
    end

    def show_json
      # TODO: Need to fix Cache issue.
      # ProductCache.fetch shadow_product, current_vendor do
        blueprint shadow_product
      # end
    end

    def blueprint(object_or_collection)
      V1::Ui::ProductBlueprint.render_as_hash object_or_collection,
        vendor: current_vendor,
        shop: current_shop
    end

    def render_index?
      last_modified = [
        products_list.map(&:updated_at).compact.max,
        products_list.map(&:deleted_at).compact.max,
      ].compact.max

      etag = [
        products_list,
        filter_params,
      ]
      stale? etag: etag, last_modified: last_modified
    end

    def filter_params
      params.permit \
        :master,
        :state,
        :unmatched,
        :sort_by,
        :sort_direction,
        :search,
        :removed,
        :disabled,
        :per_page
    end

    def set_product_pending
      return unless shadow_product
        .product_errors
        .unscoped
        .count
        .zero?

      config = current_shop.vendor_config_for current_vendor

      shadow_product
        .product
        .dispersals
        .where(vendor_shop_configuration: config)
        .update(state: :pending)
    end

    def original_price
      @original_price ||= ProductPrice.create! \
        params[:original_price].permit(:currency, :cents, :expires_at)
    rescue NoMethodError
      nil
    end

    def offer_price
      @offer_price ||= ProductPrice.create! \
        params[:offer_price].permit(:currency, :cents, :expires_at)
    rescue NoMethodError
      nil
    end

    def platinum_keywords
      create_hash(params[:platinum_keywords]&.values)
    end

    def key_features
      create_hash(params[:key_features]&.values)
    end

    def create_hash(values)
      return {} unless values.present?
      Hash[values.collect.with_index { |value, i| [i+1,value] } ]
    end

    def update_product_required
      shadow_product.product.update_attributes(update_scheduled: true)
    end

    def update_shadow_product_master_sku
      ShadowProduct.where(master_id: shadow_product.id).update(master_sku: params[:sku]) if shadow_product.master_id.nil?
    end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/ClassLength
