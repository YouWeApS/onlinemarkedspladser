class AddPositionToImportMap < ActiveRecord::Migration[5.2]
  def change
    add_column :import_maps, :position, :integer, default: 0, null: false
    add_index :import_maps, :position
  end
end
