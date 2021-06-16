# frozen_string_literal: true

class AddProductErrorsCountToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :product_errors_count, :integer, null: false, default: 0
    add_index :products, :product_errors_count
  end
end
