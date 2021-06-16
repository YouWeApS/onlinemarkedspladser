# frozen_string_literal: true

class AddProductParseConfigToVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_shop_configurations,
      :product_parse_config,
      :json,
      null: false,
      default: {}
  end
end
