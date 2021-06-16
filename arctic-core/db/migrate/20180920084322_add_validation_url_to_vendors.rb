class AddValidationUrlToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :validation_url, :string
    add_index :vendors, :validation_url
  end
end
