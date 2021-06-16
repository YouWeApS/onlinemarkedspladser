class CreateOrderLines < ActiveRecord::Migration[5.2]
  def change
    create_table :order_lines do |t|
      t.string :line_id, null: false
      t.uuid :order_id
      t.string :status, null: false, default: 'pending'
      t.string :product_id, null: false
      t.integer :quantity, null: false, default: 0
      t.string :track_and_trace_reference

      t.timestamps
    end

    add_index :order_lines, :order_id
    add_index :order_lines, :status
    add_index :order_lines, :product_id
    add_index :order_lines, :quantity
  end
end
