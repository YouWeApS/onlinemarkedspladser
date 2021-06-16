class AddEnabledFieldForShadowProduct < ActiveRecord::Migration[5.2]
  add_column :shadow_products, :enabled, :boolean, null: false, default: false
  add_index :shadow_products, :enabled
end
