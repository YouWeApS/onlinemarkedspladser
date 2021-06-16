class MigratePriceReferencesFromProductPricesToProducts < ActiveRecord::Migration[5.2]
  def up
    ProductPrice.where('expires_at > now()').find_each do |pp|
      if pp.type == 'original'
        update_relations pp, :original
      else
        update_relations pp, :offer
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

    def update_relations(pp, type)
      if pp.product_id
        Product.find(pp.product_id).update "#{type}_price_id" => pp.id
      elsif pp.shadow_product_id
        ShadowProduct.find(pp.shadow_product_id).update "#{type}_price_id" => pp.id
      end
    end
end
