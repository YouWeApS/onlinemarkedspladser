# frozen_string_literal: true

class AddLastSyncedAtToVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_shop_configurations, :last_synced_at, :datetime
    add_index :vendor_shop_configurations, :last_synced_at
  end
end
