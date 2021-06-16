# frozen_string_literal: true

class AddMaterialToProductShadows < ActiveRecord::Migration[5.2]
  def change
    add_column :shadow_products, :material, :string
  end
end
