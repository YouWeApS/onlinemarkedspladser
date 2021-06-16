class CreateProductErrorsTriggers < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION product_errors_updated_function()
      RETURNS TRIGGER AS $$
        BEGIN
          UPDATE products_list
          SET product_error_count = (
                SELECT count(*)
                FROM product_errors
                WHERE product_errors.product_id = NEW.product_id
                  AND product_errors.vendor_id = NEW.vendor_id
                  AND product_errors.deleted_at IS NULL
              ),
              updated_at = now()
          WHERE products_list.vendor_id = NEW.vendor_id
            AND products_list.sku = NEW.product_id
            AND products_list.deleted_at IS NULL;

          RETURN NEW;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER product_errors_updated_trigger
      AFTER INSERT OR UPDATE ON product_errors
      FOR EACH ROW
      EXECUTE PROCEDURE product_errors_updated_function();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS product_errors_updated_trigger
      ON product_errors;

      DROP FUNCTION product_errors_updated_function
    SQL
  end
end
