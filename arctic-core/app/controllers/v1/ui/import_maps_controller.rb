# frozen_string_literal: true

class V1::Ui::ImportMapsController < V1::Ui::ApplicationController
  def destroy
    doorkeeper_authorize! 'product:write'
    import_map&.destroy!
    render_config
  end

  def update
    doorkeeper_authorize! 'product:write'
    import_map&.update map_params
    render_config
  end

  def create
    doorkeeper_authorize! 'product:write'
    current_vendor_config.import_maps.create map_params
    render_config
  end

  private

    def import_map
      @import_map ||= current_vendor_config.import_maps.find params[:id]
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def render_config
      json = V1::Ui::VendorBlueprint.render current_vendor_config.vendor, shop: current_vendor_config.shop
      render json: json
    end

    def map_params
      params.permit :from, :to, :position, :regex, :default
    end
end
