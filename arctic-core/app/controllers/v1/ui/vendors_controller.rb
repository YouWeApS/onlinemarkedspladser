# frozen_string_literal: true

class V1::Ui::VendorsController < V1::Ui::ApplicationController #:nodoc:
  # List all vendors without any scoping of any kind.
  # See the #index method for vendors scoped to a specific shop and filtered by
  # collection and dispersal vendors.
  def all
    doorkeeper_authorize! 'product:read'

    vendors = Vendor.includes :channel

    last_modified = [
      vendors.maximum(:updated_at),
      VendorShopConfiguration.where(vendor: vendors).maximum(:updated_at),
    ].compact.max

    render json: V1::Ui::VendorBlueprint.render(vendors) if http_cache \
      vendors,
      last_modified
  end

  def create
    doorkeeper_authorize! 'product:write'

    config = configs.new \
      vendor: Vendor.find(params[:vendor_id]),
      auth_config: {}

    config.save!

    render \
      json: V1::Ui::VendorBlueprint.render(config.vendor),
      status: 201
  end

  # Lists vendors scoped to a current shop, and grouped by dispersal and
  # collection vendors.
  def index
    doorkeeper_authorize! 'product:read'

    vendors = configs.collect(&:vendor)

    # Calculate most recent updated_at date between both the configs and the
    # vendors
    last_modified = configs
      .collect(&:updated_at)
      .concat(vendors.collect(&:updated_at))
      .max

    # Blueprinter options
    options = {
      shop: shop,
    }

    render json: V1::Ui::VendorBlueprint.render(vendors, options) if http_cache vendors, last_modified
  end

  private

    def shop
      @shop ||= current_user
        .shops
        .includes(:dispersal_vendor_configurations)
        .includes(:collection_vendor_configurations)
        .find(params[:shop_id])
    end

    def configs
      # Determine configuration relation based on type parameter
      klass = case params[:type]
      when 'collection' then 'VendorShopCollectionConfiguration'
      when 'dispersal' then 'VendorShopDispersalConfiguration'
      else 'VendorShopConfiguration'
      end

      # Load configurations and collect vendors
      klass.constantize.where(shop: shop)
    end

    def http_cache(vendors, last_modified)
      stale? etag: vendors, last_modified: last_modified
    end
end
