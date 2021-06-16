class AddConfigSchemaToChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :config_schema, :json, default: {}, null: false
  end
end
