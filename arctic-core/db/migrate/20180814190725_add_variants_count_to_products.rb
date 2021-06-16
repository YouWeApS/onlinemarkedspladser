# frozen_string_literal: true

class AddVariantsCountToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :variants_count, :integer, null: false, default: 0
    add_index :products, :variants_count
  end
end
