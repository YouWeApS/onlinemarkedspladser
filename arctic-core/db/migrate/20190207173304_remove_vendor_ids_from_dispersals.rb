class RemoveVendorIdsFromDispersals < ActiveRecord::Migration[5.2]
  def change
    remove_column :dispersals, :vendor_id
  end
end
