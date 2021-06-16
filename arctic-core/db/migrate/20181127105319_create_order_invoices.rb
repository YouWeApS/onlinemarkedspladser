class CreateOrderInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :order_invoices do |t|
      t.uuid :order_id
      t.string :invoice_id
      t.string :status
      t.integer :cents
      t.string :currency

      t.timestamps
    end

    add_index :order_invoices, :order_id
    add_index :order_invoices, :status
  end
end
