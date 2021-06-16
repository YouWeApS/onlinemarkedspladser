# frozen_string_literal: true

class AddCategoryMapJsonSchemaToChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :category_map_json_schema, :json, default: {}, null: false
  end
end
