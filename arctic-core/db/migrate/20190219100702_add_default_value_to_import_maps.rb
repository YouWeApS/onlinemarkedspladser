class AddDefaultValueToImportMaps < ActiveRecord::Migration[5.2]
  def change
    add_column :import_maps, :default, :string
  end
end
