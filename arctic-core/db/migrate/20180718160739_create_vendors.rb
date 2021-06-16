# frozen_string_literal: true

class CreateVendors < ActiveRecord::Migration[5.2]
  def change
    create_table :vendors, id: :uuid do |t|
      t.uuid :token, null: false
      t.timestamps
    end

    add_index :vendors, :token, unique: true
  end
end
