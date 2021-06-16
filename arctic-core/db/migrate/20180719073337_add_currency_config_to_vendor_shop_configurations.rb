# frozen_string_literal: true

class AddCurrencyConfigToVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_shop_configurations, :currency_config, :json, null: false, default: {}
  end
end
