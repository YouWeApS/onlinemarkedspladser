class UpdateShadowProductFk < ActiveRecord::Migration[5.2]
  def up
    ShadowProduct.all.each do |s|
      product = Product.where(sku: s.product_id).first
      if product
        new_id = product.id
        s.update_columns(product_id: new_id)
      else
        s.delete
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
