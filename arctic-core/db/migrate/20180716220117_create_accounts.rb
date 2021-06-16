# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :accounts, :name, unique: true
  end
end
