# frozen_string_literal: true

class AddNameToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :name, :string
    add_index :vendors, :name
    add_index :vendors, %i[channel_id name], unique: true
  end
end
