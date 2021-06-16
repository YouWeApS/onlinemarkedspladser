# frozen_string_literal: true

class AddDispersedAtToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :dispersed_at, :datetime
    add_index :shops, :dispersed_at
  end
end
