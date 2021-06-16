# frozen_string_literal: true

class CreateShadowProductAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :shadow_product_attributes do |t|
      t.uuid :shadow_product_id, null: false
      t.string :field, null: false
      t.string :value, null: false

      t.timestamps
    end
    add_index :shadow_product_attributes, :shadow_product_id
    add_index :shadow_product_attributes, :field
    add_index :shadow_product_attributes, %i[field shadow_product_id], unique: true
  end
end
