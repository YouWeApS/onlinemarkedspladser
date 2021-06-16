class AddOriginalPriceAndOfferPriceIdsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :offer_price_id, :uuid
    add_column :products, :original_price_id, :uuid
    add_index :products, :offer_price_id
    add_index :products, :original_price_id

    add_column :shadow_products, :offer_price_id, :uuid
    add_column :shadow_products, :original_price_id, :uuid
    add_index :shadow_products, :offer_price_id
    add_index :shadow_products, :original_price_id
  end
end
