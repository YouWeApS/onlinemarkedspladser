class AddVendorIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :vendor_id, :uuid
    add_index :orders, :vendor_id
    add_index :orders, %i[order_id shop_id vendor_id], unique: true
  end
end
