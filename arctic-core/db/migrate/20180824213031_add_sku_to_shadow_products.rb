# frozen_string_literal: true

class AddSkuToShadowProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :shadow_products, :sku, :string
    add_index :shadow_products, :sku
  end
end
