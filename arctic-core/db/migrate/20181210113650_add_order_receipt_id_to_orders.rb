class AddOrderReceiptIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :order_receipt_id, :string
  end
end
