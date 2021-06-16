class EnforceOrdersVendorIdOnDbLevel < ActiveRecord::Migration[5.2]
  def change
    change_column_null :orders, :vendor_id, false
  end
end
