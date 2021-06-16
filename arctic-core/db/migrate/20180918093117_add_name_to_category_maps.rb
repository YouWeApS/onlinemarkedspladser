class AddNameToCategoryMaps < ActiveRecord::Migration[5.2]
  def change
    add_column :category_maps, :name, :string
    add_index :category_maps, :name
  end
end
