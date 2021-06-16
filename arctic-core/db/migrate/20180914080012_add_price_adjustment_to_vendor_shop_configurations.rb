class AddPriceAdjustmentToVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_shop_configurations, :price_adjustment_value, :float, null: false, default: 0.0
    add_column :vendor_shop_configurations, :price_adjustment_type, :string, null: false, default: :percent

    add_index :vendor_shop_configurations, :price_adjustment_type
  end
end
