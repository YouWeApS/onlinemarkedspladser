# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[5.2]
  CHARACTERISTICS = %i[
    size
    color
    description
    ean
    manufacturer
    brand
  ]

  def change
    create_table :products, id: false do |t|
      t.string :sku, null: false, primary: true
      t.uuid :shop_id, null: false
      t.string :name, null: false
      t.string :master_sku
      t.integer :stock_count, null: false, default: 0

      CHARACTERISTICS.each do |characteristic|
        t.string characteristic
      end

      t.timestamps
    end

    add_index :products, :shop_id
    add_index :products, :name
    add_index :products, :master_sku
    add_index :products, :sku, unique: true, using: :btree
    add_index :products, :stock_count

    CHARACTERISTICS.each do |characteristic|
      add_index :products, characteristic
    end
  end
end
