class AddShadowProductIdToProductErrors < ActiveRecord::Migration[5.2]
  def change
    add_column :product_errors, :shadow_product_id, :uuid
    add_index :product_errors, :shadow_product_id
  end
end
