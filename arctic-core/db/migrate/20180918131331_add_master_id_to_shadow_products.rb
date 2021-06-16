class AddMasterIdToShadowProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :shadow_products, :master_id, :uuid
    add_column :shadow_products, :variant_ids, :json, default: [], null: false
  end
end
