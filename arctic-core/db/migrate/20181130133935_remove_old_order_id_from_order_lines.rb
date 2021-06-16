class RemoveOldOrderIdFromOrderLines < ActiveRecord::Migration[5.2]
  def change
    remove_column :order_lines, :old_order_id
  end
end
