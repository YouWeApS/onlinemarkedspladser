class AddShadowProductIdToProductPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :product_prices, :shadow_product_id, :uuid
    add_index :product_prices, :shadow_product_id
  end
end
