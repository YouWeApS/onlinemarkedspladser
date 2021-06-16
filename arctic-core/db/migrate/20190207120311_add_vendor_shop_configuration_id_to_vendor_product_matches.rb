class AddVendorShopConfigurationIdToVendorProductMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_product_matches, :vendor_shop_configuration_id, :uuid
    add_index :vendor_product_matches, :vendor_shop_configuration_id

    VendorProductMatch.reset_column_information

    VendorProductMatch.find_each do |match|
      vendor = Vendor.find match.vendor_id
      match.vendor_shop_configuration_id = match.product.shop.vendor_config_for(vendor).id
      match.save!
    end

    change_column_null :vendor_product_matches, :vendor_shop_configuration_id, false
  end

  def down
    remove_column :vendor_product_matches, :vendor_shop_configuration_id
  end
end
