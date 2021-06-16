# frozen_string_literal: true

class ChangeOrderPrimaryKey < ActiveRecord::Migration[5.2]
  def up
    execute "ALTER TABLE orders DROP CONSTRAINT orders_pkey;"
    remove_columns :orders, :id
    rename_column :orders, :channel_reference, :id
    execute "ALTER TABLE orders ADD PRIMARY KEY (id);"
  end

  def down
    execute "ALTER TABLE orders DROP CONSTRAINT orders_pkey;"
    rename_column :orders, :id, :channel_reference
    add_column :orders, :id, :uuid, default: 'gen_random_uuid()'
    execute "ALTER TABLE orders ADD PRIMARY KEY (id);"
  end
end
