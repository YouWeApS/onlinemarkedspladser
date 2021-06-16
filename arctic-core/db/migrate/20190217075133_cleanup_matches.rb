class CleanupMatches < ActiveRecord::Migration[5.2]
  def up
    VendorProductMatch.unscoped.where(vendor_shop_configuration_id: nil).delete_all
    Dispersal.unscoped.where(vendor_shop_configuration_id: nil).delete_all
    change_column_null :vendor_product_matches, :vendor_shop_configuration_id, false
    change_column_null :dispersals, :vendor_shop_configuration_id, false
  end

  def down
  end
end
