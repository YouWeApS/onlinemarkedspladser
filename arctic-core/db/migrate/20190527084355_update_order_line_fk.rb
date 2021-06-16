class UpdateOrderLineFk < ActiveRecord::Migration[5.2]
  def up
    OrderLine.all.each do |o|
      product = Product.where(sku: o.product_id).first
      if product
        new_id = product.id
        o.update_columns(product_id: new_id)
      else
        o.delete
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
