# frozen_string_literal: true

class RemoveShadowProductAttributes < ActiveRecord::Migration[5.2]
  def change
    drop_table :shadow_product_attributes
  end
end
