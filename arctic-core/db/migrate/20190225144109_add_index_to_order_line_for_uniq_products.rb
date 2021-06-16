class AddIndexToOrderLineForUniqProducts < ActiveRecord::Migration[5.2]
  def up
    duplicated_order_lines = OrderLine.unscoped {OrderLine.select(:order_id)
                                                     .group(:product_id, :order_id)
                                                     .having("count(*) > 1")}

    duplicated_order_lines.each do |order_line|
      order_lines = OrderLine.unscoped {OrderLine.where(order_id: order_line.order_id)}
      updated_order = order_lines.max_by(&:status)
      removed_orders = order_lines.where("id != ?", updated_order.id)
      removed_orders.each {|a| a.really_destroy!}
    end

    add_index :order_lines, [:product_id, :order_id], unique: true
  end

  def down
    remove_index :order_lines, column: [:product_id, :order_id]
  end
end
