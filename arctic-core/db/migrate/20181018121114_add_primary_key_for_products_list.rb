class AddPrimaryKeyForProductsList < ActiveRecord::Migration[5.2]
  def up
    add_column :products_list, :id, :uuid, default: 'gen_random_uuid()'
    execute "ALTER TABLE products_list ADD PRIMARY KEY (id);"
  end

  def down
    execute "ALTER TABLE products_list DROP CONSTRAINT products_list_pkey;"
    remove_column :products_list, :id
  end
end
