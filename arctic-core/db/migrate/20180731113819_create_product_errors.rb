# frozen_string_literal: true

class CreateProductErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :product_errors do |t|
      t.string :message, null: false
      t.text :details
      t.string :product_id, null: false
      t.timestamps
    end

    add_index :product_errors, :product_id
  end
end
