class RemoveOriginalPriceInProductPrices < ActiveRecord::Migration[5.2]
  def change
    return unless column_exists? :product_prices, :original_price

    remove_column :product_prices, :original_price
  end
end
