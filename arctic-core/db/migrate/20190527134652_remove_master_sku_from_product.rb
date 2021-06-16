class RemoveMasterSkuFromProduct < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :master_sku
  end
end
