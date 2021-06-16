# frozen_string_literal: true

class AddShadowFieldsDirectlyToShadowProduct < ActiveRecord::Migration[5.2]
  def change
    %w[
      name
      description
      ean
      brand
      manufacturer
      color
    ].each do |field|
      add_column :shadow_products, field, :string
    end
  end
end
