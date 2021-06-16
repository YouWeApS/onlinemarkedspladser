class AddIndexToShadowProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :shadow_products, :deleted_at
  end
end
