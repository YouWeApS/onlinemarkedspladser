class AddEnabledToVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_shop_configurations, :enabled, :boolean, default: true
    add_index :vendor_shop_configurations, :enabled
  end
end
