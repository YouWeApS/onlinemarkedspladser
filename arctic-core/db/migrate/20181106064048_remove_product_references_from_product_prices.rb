class RemoveProductReferencesFromProductPrices < ActiveRecord::Migration[5.2]
  def change
    remove_column :product_prices, :product_id
    remove_column :product_prices, :shadow_product_id
    remove_column :product_prices, :type
  end
end
