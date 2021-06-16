class TruncateShadowProductData < ActiveRecord::Migration[5.2]
  def up
    ShadowProduct.find_each do |s|
      Product::CHARACTERISTICS.except('description').each do |field|
        s.public_send "#{field}=", s.public_send(field).to_s[0, 256].presence
      end

      s.description = s.description.to_s[0, 2000].presence

      s.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
