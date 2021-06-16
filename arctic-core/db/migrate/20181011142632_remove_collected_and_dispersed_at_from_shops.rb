class RemoveCollectedAndDispersedAtFromShops < ActiveRecord::Migration[5.2]
  def change
    remove_column :shops, :collected_at, :datetime
    remove_column :shops, :dispersed_at, :datetime
  end
end
