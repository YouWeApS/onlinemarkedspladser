# frozen_string_literal: true

class AddSizeToShadowProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :shadow_products, :size, :string
  end
end
