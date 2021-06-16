class UpdateRawProductDataFk < ActiveRecord::Migration[5.2]
  def up
    RawProductData.all.each do |r|
      product = Product.where(sku: r.product_id).first
      if product
        new_id = product.id
        r.update_columns(product_id: new_id)
      else
        r.delete
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
