class AddRegexToImportMaps < ActiveRecord::Migration[5.2]
  def change
    add_column :import_maps, :regex, :string
  end
end
