class RemoveProductAndVendorFromProductErrors < ActiveRecord::Migration[5.2]
  def change
    remove_index :product_errors, :product_id
    remove_index :product_errors, :vendor_id
    remove_column :product_errors, :product_id
    remove_column :product_errors, :vendor_id
  end
end
