# frozen_string_literal: true

class CreateProductImages < ActiveRecord::Migration[5.2]
  def change
    create_table :product_images, id: :uuid do |t|
      t.string :url, null: false
      t.integer :position, null: false, default: 0
      t.string :product_id, null: false
      t.timestamps
    end

    add_index :product_images, :url
    add_index :product_images, :product_id
  end
end
