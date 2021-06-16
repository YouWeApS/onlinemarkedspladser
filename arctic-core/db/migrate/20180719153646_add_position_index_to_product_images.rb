# frozen_string_literal: true

class AddPositionIndexToProductImages < ActiveRecord::Migration[5.2]
  def change
    add_index :product_images, :position
  end
end
