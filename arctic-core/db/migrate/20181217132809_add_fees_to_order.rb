class AddFeesToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :shipping_fee, :integer, default: 0, null: false
    add_column :orders, :payment_fee, :integer, default: 0, null: false

    add_index :orders, :shipping_fee
    add_index :orders, :payment_fee
  end
end
