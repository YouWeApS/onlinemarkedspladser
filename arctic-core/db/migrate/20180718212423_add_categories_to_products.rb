# frozen_string_literal: true

class AddCategoriesToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :categories, :json, null: false, default: []
  end
end
