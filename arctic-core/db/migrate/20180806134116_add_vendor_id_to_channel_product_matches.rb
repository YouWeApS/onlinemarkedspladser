# frozen_string_literal: true

class AddVendorIdToChannelProductMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :channel_product_matches, :vendor_id, :uuid
    add_index :channel_product_matches, :vendor_id
  end
end
