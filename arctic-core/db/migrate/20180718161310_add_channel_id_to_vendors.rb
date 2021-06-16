# frozen_string_literal: true

class AddChannelIdToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :channel_id, :uuid, null: false
    add_index :vendors, :channel_id
  end
end
