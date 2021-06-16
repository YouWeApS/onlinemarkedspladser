class CreateImportMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :import_maps do |t|
      t.uuid :vendor_shop_configuration_id, uuid: false
      t.string :from, null: false
      t.string :to, null: false

      t.timestamps
    end

    add_index :import_maps, :vendor_shop_configuration_id
    add_index :import_maps, :from
    add_index :import_maps, :to
  end
end
