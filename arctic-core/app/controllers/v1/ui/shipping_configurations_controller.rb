# frozen_string_literal: true

class V1::Ui::ShippingConfigurationsController < V1::Ui::ApplicationController
  def destroy
    doorkeeper_authorize! 'product:write'
    configuration&.destroy!
    render_config
  end

  def update
    doorkeeper_authorize! 'product:write'
  end

  def create
    doorkeeper_authorize! 'product:write'
    current_vendor_config.shipping_configurations.create shipping_config_params
    render_config
  end

  private

    def configuration
      @configuration ||= current_vendor_config.shipping_configurations.find params[:id]
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def render_config
      json = V1::Ui::VendorBlueprint.render current_vendor_config.vendor, shop: current_vendor_config.shop
      render json: json
    end

    def shipping_config_params
      params.permit :vendor_method, :vendor_carrier, :shipping_method_id, :shipping_carrier_id
    end
end
