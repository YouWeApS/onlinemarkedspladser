class AddTypeToProductPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :product_prices, :type, :string, default: :offer
    add_index :product_prices, :type
  end
end
