class DropChannelStoreIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :channel_store_configurations, name: :channel_store_unique
  end
end
