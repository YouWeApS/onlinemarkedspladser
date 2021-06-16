class RemoveProductFormatSchemaFromChannels < ActiveRecord::Migration[5.2]
  def change
    remove_column :channels, :product_format_schema
  end
end
