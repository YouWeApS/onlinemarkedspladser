class CreateDispersalTriggers < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION dispersals_updated_function()
      RETURNS TRIGGER AS $$
        BEGIN
          IF NEW.state = 'completed' THEN
            UPDATE products_list
            SET last_synced_at = NEW.updated_at,
                dispersal_state = NEW.state,
                updated_at = now()
            WHERE products_list.vendor_id = NEW.vendor_id
            AND products_list.sku = NEW.product_id
            AND products_list.deleted_at IS NULL;
          END IF;

          RETURN NEW;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER dispersals_updated_trigger
      AFTER INSERT OR UPDATE ON dispersals
      FOR EACH ROW
      EXECUTE PROCEDURE dispersals_updated_function();
    SQL

    Dispersal.find_each { |d| d.update updated_at: Time.zone.now }
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS dispersals_updated_trigger
      ON dispersals;

      DROP FUNCTION dispersals_updated_function
    SQL
  end
end
