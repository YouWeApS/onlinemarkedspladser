class UseVendorConfigurationIdInDispersalsUpdatedFunction < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.dispersals_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              BEGIN
                UPDATE products_list
                SET last_synced_at = NEW.updated_at,
                    dispersal_state = NEW.state,
                    updated_at = now()
                WHERE products_list.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                AND products_list.sku = NEW.product_id
                AND products_list.deleted_at IS NULL;

                RETURN NEW;
              END
            $$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.dispersals_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
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
            $$;
    SQL
  end
end
