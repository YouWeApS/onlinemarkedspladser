class UniqueProductErrorMessages < ActiveRecord::Migration[5.2]
  def up
    ProductError.delete_all

    add_index \
      :product_errors,
      %i[message details product_id vendor_id],
      unique: true,
      name: :unique_error

    Rails.cache.clear
  end

  def down
    remove_index :product_errors, %i[message details product_id vendor_id]
  end
end
