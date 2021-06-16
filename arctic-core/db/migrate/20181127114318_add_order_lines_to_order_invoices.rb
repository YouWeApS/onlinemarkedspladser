class AddOrderLinesToOrderInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :order_invoices, :order_lines, :json, default: [], null: false
  end
end
