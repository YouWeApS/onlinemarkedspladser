class EnforceCharacteristicsLengthsOnProducts < ActiveRecord::Migration[5.2]
  def up
    Product::CHARACTERISTICS.except('description').each do |field|
      change_column :shadow_products, field, :string, limit: 256
    end
    change_column :shadow_products, :description, :string, limit: 2000
  end

  def down
    Product::CHARACTERISTICS.each do |field|
      change_column :shadow_products, field, :string
    end
  end
end
