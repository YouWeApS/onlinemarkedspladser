class RemoveVendorIdsFromVendorProductMatches < ActiveRecord::Migration[5.2]
  def change
    remove_column :vendor_product_matches, :vendor_id
  end
end
