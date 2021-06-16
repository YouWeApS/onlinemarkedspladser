# frozen_string_literal: true

class AddConfigToVendorShopConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_shop_configurations, :config, :json, null: false, default: {}
  end
end
