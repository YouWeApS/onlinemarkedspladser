# frozen_string_literal: true

class ChangeProductMatchErrorColumnToArray < ActiveRecord::Migration[5.2]
  def change
    add_column :vendor_product_matches, :json_error, :json, default: []
    VendorProductMatch.reset_column_information
    VendorProductMatch.find_each do |match|
      match.update json_error: match.error.split(",")
    end
    remove_column :vendor_product_matches, :error
    rename_column :vendor_product_matches, :json_error, :error
  end
end
