class DropVendorMatchesCountFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :vendor_product_matches_count, :integer, null: false, default: 0
  end
end
