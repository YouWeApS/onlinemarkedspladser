# frozen_string_literal: true

class AddVendorIdToProductErrors < ActiveRecord::Migration[5.2]
  def change
    add_column :product_errors, :vendor_id, :uuid, null: false
    add_index :product_errors, :vendor_id
  end
end
