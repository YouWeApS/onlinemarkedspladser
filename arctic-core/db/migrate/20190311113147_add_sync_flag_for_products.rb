class AddSyncFlagForProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :update_scheduled, :boolean, null: false, default: false
    add_index :products, :update_scheduled
  end
end
