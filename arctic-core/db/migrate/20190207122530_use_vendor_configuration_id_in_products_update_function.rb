class UseVendorConfigurationIdInProductsUpdateFunction < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.products_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              BEGIN
                IF (TG_OP = 'DELETE') THEN
                  DELETE FROM products_list
                  WHERE products_list.sku = NEW.sku;
                ELSE
                  UPDATE products_list
                  SET name = COALESCE(
                        (
                          SELECT name
                          FROM shadow_products
                          WHERE shadow_products.vendor_shop_configuration_id = products_list.vendor_shop_configuration_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.name
                      ),
                      ean = COALESCE(
                        (
                          SELECT ean
                          FROM shadow_products
                          WHERE shadow_products.vendor_shop_configuration_id = products_list.vendor_shop_configuration_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.ean
                      ),
                      sku = COALESCE(
                        (
                          SELECT product_id
                          FROM shadow_products
                          WHERE shadow_products.vendor_shop_configuration_id = products_list.vendor_shop_configuration_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.sku
                      ),
                      updated_at = now()
                  WHERE products_list.sku = NEW.sku
                    AND products_list.deleted_at IS NULL;
                END IF;

                RETURN NEW;
              END
            $$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.products_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              BEGIN
                IF (TG_OP = 'DELETE') THEN
                  DELETE FROM products_list
                  WHERE products_list.sku = NEW.sku;
                ELSE
                  UPDATE products_list
                  SET name = COALESCE(
                        (
                          SELECT name
                          FROM shadow_products
                          WHERE shadow_products.vendor_id = products_list.vendor_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.name
                      ),
                      ean = COALESCE(
                        (
                          SELECT ean
                          FROM shadow_products
                          WHERE shadow_products.vendor_id = products_list.vendor_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.ean
                      ),
                      sku = COALESCE(
                        (
                          SELECT product_id
                          FROM shadow_products
                          WHERE shadow_products.vendor_id = products_list.vendor_id
                            AND shadow_products.product_id = NEW.sku
                            AND shadow_products.deleted_at IS NULL
                        ),
                        NEW.sku
                      ),
                      updated_at = now()
                  WHERE products_list.sku = NEW.sku
                    AND products_list.deleted_at IS NULL;
                END IF;

                RETURN NEW;
              END
            $$;
    SQL
  end
end
