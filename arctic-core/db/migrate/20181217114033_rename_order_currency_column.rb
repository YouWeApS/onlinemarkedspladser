class RenameOrderCurrencyColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :total_currency, :currency
    change_column_default :orders, :currency, from: nil, to: 'DKK'
    change_column_null :orders, :currency, false
  end
end
