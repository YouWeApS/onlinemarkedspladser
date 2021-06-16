# frozen_string_literal: true

class CreateShops < ActiveRecord::Migration[5.2]
  def change
    create_table :shops, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :shops, :account_id
    add_index :shops, :name, unique: true
  end
end
