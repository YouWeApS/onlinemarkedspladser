# frozen_string_literal: true

class CreateDispersals < ActiveRecord::Migration[5.2]
  def change
    create_table :dispersals do |t|
      t.string :product_id
      t.uuid :vendor_id

      t.timestamps
    end
    add_index :dispersals, :product_id
    add_index :dispersals, :vendor_id
  end
end
