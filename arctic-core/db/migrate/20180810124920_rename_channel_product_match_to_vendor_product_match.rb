# frozen_string_literal: true

class RenameChannelProductMatchToVendorProductMatch < ActiveRecord::Migration[5.2]
  def change
    rename_table :channel_product_matches, :vendor_product_matches
  end
end
