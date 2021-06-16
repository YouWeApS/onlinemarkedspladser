# frozen_string_literal: true

class AddProductFormatSchemaToChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :product_format_schema, :json, null: false, default: {}
  end
end
