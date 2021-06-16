# frozen_string_literal: true

class AddAuthConfigToChannelStoreConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :channel_store_configurations, :auth_config, :text
  end
end
