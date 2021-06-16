class AddPriceAndVatToOrderLines < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :vat, :float, default: 25.0, null: false

    add_column :order_lines, :cents_without_vat, :integer
    add_column :order_lines, :cents_with_vat, :integer

    add_index :order_lines, :cents_with_vat
    add_index :order_lines, :cents_without_vat
    add_index :orders, :vat
  end
end
