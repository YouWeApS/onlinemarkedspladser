# frozen_string_literal: true

class CreateChannelStoreConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :channel_store_configurations, id: :uuid do |t|
      t.uuid :shop_id, null: false
      t.uuid :channel_id, null: false
      t.string :type, null: false, default: 'ChannelStoreDispersalConfiguration'
      t.timestamps
    end

    add_index :channel_store_configurations, :shop_id
    add_index :channel_store_configurations, :channel_id
    add_index :channel_store_configurations, :type
    add_index :channel_store_configurations, %i[shop_id channel_id],
      name: :channel_store_unique,
      unique: true
  end
end
