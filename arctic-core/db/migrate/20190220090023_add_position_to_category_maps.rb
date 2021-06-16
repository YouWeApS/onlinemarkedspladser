class AddPositionToCategoryMaps < ActiveRecord::Migration[5.2]
  def change
    add_column :category_maps, :position, :integer, default: 0, null: false
    add_index :category_maps, :position
  end
end
