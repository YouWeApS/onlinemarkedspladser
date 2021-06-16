class UpdateVersionFk < ActiveRecord::Migration[5.2]
  def up
    sql = "SELECT * from versions WHERE item_type = 'Product'"
    result = ActiveRecord::Base.connection.execute(sql)
    result.each do |p|
      product = Product.where(sku: p['item_id']).first
      if product
        new_id = product.id
        insert_sql = "UPDATE versions SET item_id = '#{new_id}' WHERE id=#{p['id']};"
        ActiveRecord::Base.connection.execute(insert_sql)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
