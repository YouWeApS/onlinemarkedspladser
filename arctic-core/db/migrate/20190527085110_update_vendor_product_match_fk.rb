class UpdateVendorProductMatchFk < ActiveRecord::Migration[5.2]
  def up
    VendorProductMatch.all.each do |v|
      shadow = ShadowProduct.where(sku: v.product_id).first
      product = shadow.present? ? Product.where(id: shadow.product_id).first : Product.find_by(sku: v.product_id)
      if product
        v.update_columns(product_id: product.id)
      else
        v.delete
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
