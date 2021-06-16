# frozen_string_literal: true

class CreateProductPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :product_prices, id: :uuid do |t|
      t.string :product_id, null: false
      t.integer :cents, null: false
      t.string :currency, null: false
      t.datetime :expires_at
      t.timestamps
    end

    add_index :product_prices, :product_id
    add_index :product_prices, :cents
    add_index :product_prices, :currency
    add_index :product_prices, :expires_at
  end
end
