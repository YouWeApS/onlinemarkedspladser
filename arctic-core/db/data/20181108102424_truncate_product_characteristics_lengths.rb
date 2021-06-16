class TruncateProductCharacteristicsLengths < ActiveRecord::Migration[5.2]
  def up
    Product.find_each do |product|
      Product::CHARACTERISTICS.except('description').each do |field|
        product.public_send "#{field}=", product.public_send(field).to_s[0, 256]
      end

      product.description = product.description.to_s[0, 2000]

      product.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
