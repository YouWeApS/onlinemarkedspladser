class AddVendorShopConfigurationIdToShadowProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :shadow_products, :vendor_shop_configuration_id, :uuid
    add_index :shadow_products, :vendor_shop_configuration_id
    remove_index :shadow_products, %i[product_id vendor_id]
    add_index :shadow_products, %i[product_id vendor_id vendor_shop_configuration_id],
      unique: true,
      name: :unique_product_for_vendor

    ShadowProduct.reset_column_information

    ShadowProduct.find_each do |shadow|
      vendor = Vendor.find shadow.vendor_id
      config = shadow.product.shop.vendor_config_for vendor
      shadow.vendor_shop_configuration_id = config.id
      shadow.save!
    end

    change_column_null :shadow_products, :vendor_shop_configuration_id, false
  end

  def down
    remove_column :shadow_products, :vendor_shop_configuration_id, :uuid
    add_index :shadow_products, %i[product_id vendor_id], unique: true
  end
end
