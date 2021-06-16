# frozen_string_literal: true

class AddCategoriesToShadowProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :shadow_products, :categories, :json, default: [], null: false
  end
end
