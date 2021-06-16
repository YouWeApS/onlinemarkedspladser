class UseVendorConfigurationIdInVendorProductMatchesFunction < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.vendor_product_matches_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              BEGIN
                UPDATE products_list
                SET match_error_count = (
                      SELECT count(*)
                      FROM vendor_product_matches
                      WHERE vendor_product_matches.vendor_shop_configuration_id = NEW.vendor_shop_configuration_id
                        AND vendor_product_matches.product_id = NEW.product_id
                        AND vendor_product_matches.matched IS FALSE
                        AND vendor_product_matches.deleted_at IS NULL
                    ),
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
      CREATE OR REPLACE FUNCTION public.vendor_product_matches_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
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
            $$;
    SQL
  end
end
