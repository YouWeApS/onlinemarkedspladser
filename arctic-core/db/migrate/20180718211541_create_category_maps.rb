# frozen_string_literal: true

class CreateCategoryMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :category_maps, id: :uuid do |t|
      t.uuid :vendor_shop_configuration_id, null: false
      t.string :source, null: false
      t.json :value, null: false, default: {}
      t.timestamps
    end

    add_index :category_maps, :vendor_shop_configuration_id
    add_index :category_maps, :source
  end
end
