# frozen_string_literal: true

class AddProductFormatterToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :product_formatter, :string
  end
end
