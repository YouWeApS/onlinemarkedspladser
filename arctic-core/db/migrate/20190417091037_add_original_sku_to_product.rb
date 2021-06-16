class AddOriginalSkuToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :original_sku, :string
  end
end
