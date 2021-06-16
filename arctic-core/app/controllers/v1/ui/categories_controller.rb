# frozen_string_literal: true

class V1::Ui::CategoriesController < V1::Ui::ApplicationController #:nodoc:
  def show
    doorkeeper_authorize! 'product:read'

    if stale? \
      etag: category_map,
      last_modified: category_map.updated_at
      render json: V1::Ui::CategoryMapBlueprint.render(category_map)
    end
  end

  def create
    doorkeeper_authorize! 'product:write'

    category = CategoryMap.new category_params
    category.vendor_shop_configuration = current_shop.vendor_config_for current_vendor

    category.save!

    render \
      status: 201,
      json: V1::Ui::CategoryMapBlueprint.render(category)
  end

  def index
    doorkeeper_authorize! 'product:read'

    if stale? \
      etag: category_maps,
      last_modified: category_maps.maximum(:updated_at)
      render json: V1::Ui::CategoryMapBlueprint.render(category_maps)
    end
  end

  def update
    doorkeeper_authorize! 'product:write'

    category_map.update category_params

    render json: V1::Ui::CategoryMapBlueprint.render(category_map)
  end

  def destroy
    doorkeeper_authorize! 'product:write'

    category_map.destroy!

    head :no_content
  end

  private

    def category_params
      params.permit :source, :name, :position, value: {}
    end

    def category_map
      @category_map ||= category_maps.find params[:id]
    end

    def category_maps
      @category_maps ||= current_shop
        .vendor_config_for(current_vendor)
        .category_maps
    end
end
