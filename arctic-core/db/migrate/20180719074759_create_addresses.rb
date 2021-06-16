# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses, id: :uuid do |t|
      t.string :name, null: false
      t.string :address1, null: false
      t.string :address2
      t.string :zip, null: false
      t.string :country, null: false
      t.string :city, null: false
      t.string :region
      t.string :phone
      t.string :email, null: false
      t.timestamps
    end

    add_index :addresses, :country
    add_index :addresses, :email
  end
end
