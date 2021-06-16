class AddIndeciesToShadowProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :shadow_products, :ean
    add_index :shadow_products, :manufacturer
    add_index :shadow_products, :color
    add_index :shadow_products, :description
    add_index :shadow_products, :name
    add_index :shadow_products, :size
    add_index :shadow_products, :brand
  end
end
