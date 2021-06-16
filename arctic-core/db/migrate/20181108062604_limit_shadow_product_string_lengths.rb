class LimitShadowProductStringLengths < ActiveRecord::Migration[5.2]
  def up
    %w[
      brand
      color
      ean
      manufacturer
      master_sku
      material
      name
      size
      sku
      gender
      count
      scent
    ].each do |field|
      change_column :shadow_products, field, :string, limit: 256
    end
  end

  def down
    %w[
      brand
      color
      ean
      manufacturer
      master_sku
      material
      name
      size
      sku
      gender
      count
      scent
    ].each do |field|
      change_column :shadow_products, field, :string
    end
  end
end
