class RemoveProductParseConfigFromVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    remove_column :vendor_shop_configurations, :product_parse_config
  end
end
