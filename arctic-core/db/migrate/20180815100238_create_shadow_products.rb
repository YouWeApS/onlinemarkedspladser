# frozen_string_literal: true

class CreateShadowProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :shadow_products, id: :uuid do |t|
      t.uuid :vendor_id, null: false
      t.string :product_id, null: false
      t.timestamps
    end

    add_index :shadow_products, :vendor_id
    add_index :shadow_products, :product_id
    add_index :shadow_products, %i[product_id vendor_id], unique: true
  end
end
