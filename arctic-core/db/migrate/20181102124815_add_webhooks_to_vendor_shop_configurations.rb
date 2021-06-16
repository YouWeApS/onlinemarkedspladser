class AddWebhooksToVendorShopConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_shop_configurations, :webhooks, :json, default: {}, null: false
  end
end
