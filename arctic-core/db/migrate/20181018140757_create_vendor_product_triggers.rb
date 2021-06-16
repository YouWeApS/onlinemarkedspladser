class CreateVendorProductTriggers < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION vendor_product_matches_updated_function()
      RETURNS TRIGGER AS $$
        BEGIN
          UPDATE products_list
          SET match_error_count = (
                SELECT count(*)
                FROM vendor_product_matches
                WHERE vendor_product_matches.vendor_id = NEW.vendor_id
                  AND vendor_product_matches.product_id = NEW.product_id
                  AND vendor_product_matches.matched IS FALSE
                  AND vendor_product_matches.deleted_at IS NULL
              ),
              updated_at = now()
          WHERE products_list.vendor_id = NEW.vendor_id
            AND products_list.sku = NEW.product_id
            AND products_list.deleted_at IS NULL;

          RETURN NEW;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER vendor_product_matches_updated_trigger
      AFTER INSERT OR UPDATE ON vendor_product_matches
      FOR EACH ROW
      EXECUTE PROCEDURE vendor_product_matches_updated_function();
    SQL

    Dispersal.find_each { |d| d.update updated_at: Time.zone.now }
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS vendor_product_matches_updated_trigger
      ON vendor_product_matches;

      DROP FUNCTION vendor_product_matches_updated_function
    SQL
  end
end
