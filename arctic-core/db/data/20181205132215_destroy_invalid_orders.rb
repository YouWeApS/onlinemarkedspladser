class DestroyInvalidOrders < ActiveRecord::Migration[5.2]
  def up
    Order.find_each do |order|
      order.destroy if order.order_lines.count.zero?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
