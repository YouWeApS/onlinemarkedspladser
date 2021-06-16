class CreateProductsListTriggers < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TRIGGER shadow_products_updated_trigger
      AFTER INSERT OR UPDATE OR DELETE ON shadow_products
      FOR EACH ROW
      EXECUTE PROCEDURE shadow_products_updated_function();
    SQL

    ShadowProduct.find_each do |shadow|
      shadow.update updated_at: Time.zone.now
    end
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS shadow_products_updated_trigger
      ON shadow_products
    SQL
  end
end
