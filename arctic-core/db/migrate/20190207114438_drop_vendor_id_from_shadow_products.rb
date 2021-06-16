class DropVendorIdFromShadowProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :shadow_products, :vendor_id
  end
end
