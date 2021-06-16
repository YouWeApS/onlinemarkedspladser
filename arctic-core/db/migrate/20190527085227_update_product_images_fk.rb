class UpdateProductImagesFk < ActiveRecord::Migration[5.2]
  def up
    ProductImage.all.each do |d|
      product = Product.where(sku: d.product_id).first
      if product
        new_id = product.id
        d.update_columns(product_id: new_id)
      else
        d.delete
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
