# frozen_string_literal: true

class ChangeShadowProductAttributePrimaryKeyToUuid < ActiveRecord::Migration[5.2]
  def up
    add_column :shadow_product_attributes, :uuid, :uuid, default: 'gen_random_uuid()'
    remove_column :shadow_product_attributes, :id # remove existing primary key
    rename_column :shadow_product_attributes, :uuid, :id # rename existing UDID column
    execute "ALTER TABLE shadow_product_attributes ADD PRIMARY KEY (id);"
  end

  def down
    raise IrreversibleMigration
  end
end
