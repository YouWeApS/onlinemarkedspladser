# frozen_string_literal: true

class AddMaterialToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :material, :string
    add_index :products, :material
  end
end
