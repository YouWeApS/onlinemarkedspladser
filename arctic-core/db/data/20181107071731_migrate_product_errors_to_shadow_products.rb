class MigrateProductErrorsToShadowProducts < ActiveRecord::Migration[5.2]
  def up
    ProductError.find_each do |pe|
      vendor = Vendor.find pe.vendor_id
      product = Product.find pe.product_id
      shadow = ShadowProduct.find_by vendor: vendor, product: product
      pe.update shadow_product_id: shadow.id if shadow
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
