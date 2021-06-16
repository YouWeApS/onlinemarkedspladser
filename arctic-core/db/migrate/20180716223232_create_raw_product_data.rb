# frozen_string_literal: true

class CreateRawProductData < ActiveRecord::Migration[5.2]
  def change
    create_table :raw_product_data, id: :uuid do |t|
      t.string :product_id, null: false
      t.jsonb :data, default: {}, null: false
      t.timestamps
    end

    add_index :raw_product_data, :product_id
    # add_index :raw_product_data, 'CAST(md5(data) AS uuid)', unique: true
  end
end
