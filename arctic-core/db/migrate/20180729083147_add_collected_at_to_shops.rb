# frozen_string_literal: true

class AddCollectedAtToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :collected_at, :datetime
    add_index :shops, :collected_at
  end
end
