# frozen_string_literal: true

class ChangeProductErrorsPrimaryKeyToUuid < ActiveRecord::Migration[5.2]
  def up
    add_column :product_errors, :uuid, :uuid, default: 'gen_random_uuid()'
    remove_column :product_errors, :id # remove existing primary key
    rename_column :product_errors, :uuid, :id # rename existing UDID column
    execute "ALTER TABLE product_errors ADD PRIMARY KEY (id);"
  end

  def down
    raise IrreversibleMigration
  end
end
