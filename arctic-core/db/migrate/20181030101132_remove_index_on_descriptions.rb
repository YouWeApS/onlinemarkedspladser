class RemoveIndexOnDescriptions < ActiveRecord::Migration[5.2]
  def change
    remove_index :products, :description
    remove_index :shadow_products, :description
  end
end
