# frozen_string_literal: true

class ChangeDispersalsPrimaryKeyToUuid < ActiveRecord::Migration[5.2]
  def up
    add_column :dispersals, :uuid, :uuid, default: 'gen_random_uuid()'
    remove_column :dispersals, :id # remove existing primary key
    rename_column :dispersals, :uuid, :id # rename existing UDID column
    execute "ALTER TABLE dispersals ADD PRIMARY KEY (id);"
  end

  def down
    raise IrreversibleMigration
  end
end
