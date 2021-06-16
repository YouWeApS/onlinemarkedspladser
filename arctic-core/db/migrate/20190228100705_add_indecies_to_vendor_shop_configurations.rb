class AddIndeciesToVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_index :vendor_shop_configurations, :deleted_at
  end
end
