class UpdateProductErrorsUpdatedFunction < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.product_errors_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              BEGIN
                UPDATE products_list
                SET product_error_count = (
                      SELECT count(*)
                      FROM product_errors
                      WHERE product_errors.shadow_product_id = NEW.shadow_product_id
                        AND product_errors.deleted_at IS NULL
                    ),
                    updated_at = now()
                WHERE products_list.shadow_product_id = NEW.shadow_product_id
                  AND products_list.deleted_at IS NULL;

                RETURN NEW;
              END
            $$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.product_errors_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
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
            $$;
    SQL
  end
end
