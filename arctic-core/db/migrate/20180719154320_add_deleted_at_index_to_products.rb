# frozen_string_literal: true

class AddDeletedAtIndexToProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :products, :deleted_at
  end
end
