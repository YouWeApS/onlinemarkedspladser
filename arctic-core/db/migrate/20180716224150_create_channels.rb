# frozen_string_literal: true

class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :channels, :name, unique: true
  end
end
