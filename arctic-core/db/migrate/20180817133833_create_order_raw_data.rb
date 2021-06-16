# frozen_string_literal: true

class CreateOrderRawData < ActiveRecord::Migration[5.2]
  def change
    create_table :order_raw_data, id: :uuid do |t|
      t.string :order_id, null: false
      t.json :data

      t.timestamps
    end

    add_index :order_raw_data, :order_id
  end
end
