# frozen_string_literal: true

class V1::Vendors::ShopsController < V1::Vendors::ApplicationController #:nodoc:
  def index
    render status: 200, json: {
      collection: collection_blueprints,
      dispersal: dispersal_blueprints,
    }
  end

  def show
    render json: V1::Vendors::ShopBlueprint.render(shop, vendor: current_vendor)
  end

  def products_synced
    config = shop.vendor_config_for current_vendor
    config.update last_synced_at: Time.zone.now
    head :no_content
  end

  def orders_synced
    config = shop.vendor_config_for current_vendor
    config.update orders_last_synced_at: Time.zone.now
    head :no_content
  end

  private

    def dispersal_shop
      dispersal_shops.where(id: params[:id]).take
    end

    def collection_shop
      collection_shops.where(id: params[:id]).take
    end

    def shop
      @shop ||= dispersal_shop || collection_shop || raise(HttpError::NotFound('no such shop'))
    end

    def dispersal_shops
      @dispersal_shops ||= paginate collection(:dispersal)
    end

    def collection_shops
      @collection_shops ||= paginate collection(:collection)
    end

    def collection_blueprints
      @collection_blueprints ||= shops_blueprints collection_shops
    end

    def dispersal_blueprints
      @dispersal_blueprints ||= shops_blueprints dispersal_shops
    end

    def shops_blueprints(shops)
      shops.collect { |shop| V1::Vendors::ShopBlueprint.render_as_hash(shop, vendor: current_vendor) }
    end

    def collection(type)
      cx = current_vendor.public_send("#{type}_shops")

      cx = cx
        .includes(:vendor_shop_configurations)
        .where(vendor_shop_configurations: { enabled: true })
        .distinct

      cx = cx.since params[:since] if params[:since]

      cx
    end
end
