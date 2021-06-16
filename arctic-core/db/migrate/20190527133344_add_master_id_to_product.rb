class AddMasterIdToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :master_id, :uuid
  end
end
