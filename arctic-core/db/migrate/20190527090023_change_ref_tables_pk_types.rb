class ChangeRefTablesPkTypes < ActiveRecord::Migration[5.2]
  def up
    insert_sql = "ALTER TABLE dispersals ALTER COLUMN product_id SET DATA TYPE UUID USING product_id::UUID;"
    ActiveRecord::Base.connection.execute(insert_sql)
    insert_sql = "ALTER TABLE order_lines ALTER COLUMN product_id SET DATA TYPE UUID USING product_id::UUID;"
    ActiveRecord::Base.connection.execute(insert_sql)
    insert_sql = "ALTER TABLE raw_product_data ALTER COLUMN product_id SET DATA TYPE UUID USING product_id::UUID;"
    ActiveRecord::Base.connection.execute(insert_sql)
    insert_sql = "ALTER TABLE shadow_products ALTER COLUMN product_id SET DATA TYPE UUID USING product_id::UUID;"
    ActiveRecord::Base.connection.execute(insert_sql)
    insert_sql = "ALTER TABLE vendor_product_matches ALTER COLUMN product_id SET DATA TYPE UUID USING product_id::UUID;"
    ActiveRecord::Base.connection.execute(insert_sql)
    insert_sql = "ALTER TABLE product_images ALTER COLUMN product_id SET DATA TYPE UUID USING product_id::UUID;"
    ActiveRecord::Base.connection.execute(insert_sql)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
