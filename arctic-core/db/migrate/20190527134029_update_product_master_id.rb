class UpdateProductMasterId < ActiveRecord::Migration[5.2]
  def up
    Product.where.not(master_sku: [nil, '']).all.each do |s|
      product = Product.where(sku: s.master_sku).first
      if product
        new_id = product.id
        s.update_columns(master_id: new_id)
      else
        s.delete
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
