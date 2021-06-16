# frozen_string_literal: true

class AddVendorProductMatchesCountToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :vendor_product_matches_count, :integer, null: false, default: 0
    add_index :products, :vendor_product_matches_count
  end
end
