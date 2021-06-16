class AddSkuFormatterToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :sku_formatter, :string, default: 'Sku'
    add_index :vendors, :sku_formatter
  end
end
