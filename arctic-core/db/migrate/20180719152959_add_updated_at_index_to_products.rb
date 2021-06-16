# frozen_string_literal: true

class AddUpdatedAtIndexToProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :products, :updated_at
  end
end
