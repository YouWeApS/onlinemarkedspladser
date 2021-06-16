class UpdateDispersalTriggersWithInprogressState < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS dispersals_updated_trigger
      ON dispersals;

      CREATE OR REPLACE FUNCTION dispersals_updated_function()
      RETURNS TRIGGER AS $$
        BEGIN
          UPDATE products_list
          SET last_synced_at = NEW.updated_at,
              dispersal_state = NEW.state,
              updated_at = now()
          WHERE products_list.vendor_id = NEW.vendor_id
          AND products_list.sku = NEW.product_id
          AND products_list.deleted_at IS NULL;

          RETURN NEW;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER dispersals_updated_trigger
      AFTER INSERT OR UPDATE ON dispersals
      FOR EACH ROW
      EXECUTE PROCEDURE dispersals_updated_function();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS dispersals_updated_trigger
      ON dispersals;

      DROP FUNCTION dispersals_updated_function
    SQL
  end
end
