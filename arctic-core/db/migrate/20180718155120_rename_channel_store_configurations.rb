# frozen_string_literal: true

class RenameChannelStoreConfigurations < ActiveRecord::Migration[5.2]
  def change
    rename_table :channel_store_configurations, :vendor_shop_configurations
    change_column_default :vendor_shop_configurations, :type,
      to: 'VendorShopDispersalConfiguration',
      from: 'Abc'
    rename_column :vendor_shop_configurations, :channel_id, :vendor_id
  end
end
