# frozen_string_literal: true

class AddAuthConfigSchemaToChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :auth_config_schema, :json, default: {}, null: false
  end
end
