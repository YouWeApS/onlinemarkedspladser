# frozen_string_literal: true

class AddDispersedAtToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :dispersed_at, :datetime
    add_index :products, :dispersed_at
  end
end
