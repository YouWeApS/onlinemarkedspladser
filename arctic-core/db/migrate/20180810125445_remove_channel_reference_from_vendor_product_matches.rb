# frozen_string_literal: true

class RemoveChannelReferenceFromVendorProductMatches < ActiveRecord::Migration[5.2]
  def change
    remove_column :vendor_product_matches, :channel_id
  end
end
