class UpdateOrderLines < ActiveRecord::Migration[5.2]
  def up
    OrderLine.find_each do |ol|
      order = Order.find_by order_id: ol.order_id
      ol.update order: order
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
