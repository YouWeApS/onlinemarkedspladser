# frozen_string_literal: true

class AddMasterSkuToShadowProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :shadow_products, :master_sku, :string
    add_index :shadow_products, :master_sku
  end
end
