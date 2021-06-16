class AddVendorShopConfigurationIdToDispersals < ActiveRecord::Migration[5.2]
  def change
    add_column :dispersals, :vendor_shop_configuration_id, :uuid
    add_index :dispersals, :vendor_shop_configuration_id

    Dispersal.reset_column_information

    Dispersal.find_each do |match|
      match.vendor_shop_configuration_id = match.product.shop.vendor_config_for(match.vendor).id
      match.save!
    end

    change_column_null :dispersals, :vendor_shop_configuration_id, false
  end

  def down
    remove_column :dispersals, :vendor_shop_configuration_id
  end
end
