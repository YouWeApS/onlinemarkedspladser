class ReadSkuFromCcharacteristicsInShadowProductsUpdatedFunction < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.shadow_products_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
                    BEGIN
                      IF (TG_OP = 'DELETE') THEN
                        DELETE FROM products_list
                        WHERE products_list.shadow_product_id = NEW.id;
                      ELSE
                        WITH upsert AS (
                          UPDATE products_list
                            SET vendor_id = NEW.vendor_id,
                                shadow_product_id = NEW.id,
                                sku = COALESCE(
                                  NEW.sku,
                                  NEW.product_id
                                ),
                                master_sku = (
                                  SELECT master_sku FROM products
                                  WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                ),
                                shop_id = (
                                  SELECT shop_id FROM products
                                  WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                ),
                                name = COALESCE(
                                  NEW.name,
                                  (
                                    SELECT name FROM products
                                    WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                  )
                                ),
                                product_error_count = (
                                  SELECT count(*) FROM product_errors
                                  WHERE product_errors.shadow_product_id = NEW.id
                                    AND product_errors.severity = 'error'
                                    AND product_errors.deleted_at IS NULL
                                ),
                                ean = COALESCE(
                                  NEW.ean,
                                  (
                                    SELECT ean FROM products
                                    WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                  )
                                ),
                                match_error_count = (
                                  SELECT count(*) FROM vendor_product_matches
                                  WHERE vendor_product_matches.product_id = NEW.product_id
                                    AND vendor_product_matches.vendor_id = NEW.vendor_id
                                    AND vendor_product_matches.matched = FALSE
                                    AND vendor_product_matches.deleted_at IS NULL
                                ),
                                last_synced_at = (
                                  SELECT updated_at FROM dispersals
                                  WHERE dispersals.product_id = NEW.product_id
                                    AND dispersals.vendor_id = NEW.vendor_id
                                    AND dispersals.state = 'completed'
                                    AND dispersals.deleted_at IS NULL
                                ),
                                dispersal_state = (
                                  SELECT state FROM dispersals
                                  WHERE dispersals.product_id = NEW.product_id
                                    AND dispersals.vendor_id = NEW.vendor_id
                                    AND dispersals.deleted_at IS NULL
                                  ORDER BY dispersals.updated_at DESC
                                  LIMIT 1
                                ),
                                deleted_at = NEW.deleted_at,
                                updated_at = now()
                            WHERE products_list.vendor_id::UUID = NEW.vendor_id::UUID
                              AND products_list.sku = NEW.product_id
                          RETURNING *)

                        INSERT INTO products_list (
                          shadow_product_id,
                          sku,
                          vendor_id,
                          deleted_at,
                          master_sku,
                          shop_id,
                          ean,
                          name,
                          product_error_count,
                          match_error_count,
                          dispersal_state,
                          last_synced_at,
                          created_at,
                          updated_at
                        ) SELECT
                          NEW.id,
                          NEW.product_id,
                          NEW.vendor_id,
                          NEW.deleted_at,
                          (
                            SELECT master_sku FROM products
                            WHERE products.sku = NEW.product_id
                              AND products.deleted_at IS NULL
                          ),
                          (
                            SELECT shop_id FROM products
                            WHERE products.sku = NEW.product_id
                              AND products.deleted_at IS NULL
                          ),
                          COALESCE(
                            NEW.ean,
                            (
                              SELECT ean FROM products
                              WHERE products.sku = NEW.product_id
                                AND products.deleted_at IS NULL
                            )
                          ),
                          COALESCE(NEW.name, (SELECT name from products where products.sku = NEW.product_id)),
                          (
                            SELECT count(*) FROM product_errors
                            WHERE product_errors.shadow_product_id = NEW.id
                              AND product_errors.severity = 'error'
                              AND product_errors.deleted_at IS NULL
                          ),
                          (
                            SELECT count(*) FROM vendor_product_matches
                            WHERE vendor_product_matches.product_id = NEW.product_id
                              AND vendor_product_matches.vendor_id = NEW.vendor_id
                              AND vendor_product_matches.matched = FALSE
                              AND vendor_product_matches.deleted_at IS NULL
                          ),
                          (
                            SELECT state FROM dispersals
                            WHERE dispersals.product_id = NEW.product_id
                              AND dispersals.vendor_id = NEW.vendor_id
                              AND dispersals.deleted_at IS NULL
                            ORDER BY dispersals.updated_at DESC
                            LIMIT 1
                          ),
                          (
                            SELECT updated_at FROM dispersals
                            WHERE dispersals.product_id = NEW.product_id
                              AND dispersals.vendor_id = NEW.vendor_id
                              AND dispersals.state = 'completed'
                              AND dispersals.deleted_at IS NULL
                          ),
                          now(),
                          now()
                        WHERE NOT EXISTS (SELECT * FROM upsert);
                      END IF;

                      RETURN NEW;
                    END
                  $$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.shadow_products_updated_function() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
                    BEGIN
                      IF (TG_OP = 'DELETE') THEN
                        DELETE FROM products_list
                        WHERE products_list.shadow_product_id = NEW.id;
                      ELSE
                        WITH upsert AS (
                          UPDATE products_list
                            SET sku = NEW.product_id,
                                vendor_id = NEW.vendor_id,
                                shadow_product_id = NEW.id,
                                master_sku = (
                                  SELECT master_sku FROM products
                                  WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                ),
                                shop_id = (
                                  SELECT shop_id FROM products
                                  WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                ),
                                name = COALESCE(
                                  NEW.name,
                                  (
                                    SELECT name FROM products
                                    WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                  )
                                ),
                                product_error_count = (
                                  SELECT count(*) FROM product_errors
                                  WHERE product_errors.shadow_product_id = NEW.id
                                    AND product_errors.severity = 'error'
                                    AND product_errors.deleted_at IS NULL
                                ),
                                ean = COALESCE(
                                  NEW.ean,
                                  (
                                    SELECT ean FROM products
                                    WHERE products.sku = NEW.product_id
                                    AND products.deleted_at IS NULL
                                  )
                                ),
                                match_error_count = (
                                  SELECT count(*) FROM vendor_product_matches
                                  WHERE vendor_product_matches.product_id = NEW.product_id
                                    AND vendor_product_matches.vendor_id = NEW.vendor_id
                                    AND vendor_product_matches.matched = FALSE
                                    AND vendor_product_matches.deleted_at IS NULL
                                ),
                                last_synced_at = (
                                  SELECT updated_at FROM dispersals
                                  WHERE dispersals.product_id = NEW.product_id
                                    AND dispersals.vendor_id = NEW.vendor_id
                                    AND dispersals.state = 'completed'
                                    AND dispersals.deleted_at IS NULL
                                ),
                                dispersal_state = (
                                  SELECT state FROM dispersals
                                  WHERE dispersals.product_id = NEW.product_id
                                    AND dispersals.vendor_id = NEW.vendor_id
                                    AND dispersals.deleted_at IS NULL
                                  ORDER BY dispersals.updated_at DESC
                                  LIMIT 1
                                ),
                                deleted_at = NEW.deleted_at,
                                updated_at = now()
                            WHERE products_list.vendor_id::UUID = NEW.vendor_id::UUID
                              AND products_list.sku = NEW.product_id
                          RETURNING *)

                        INSERT INTO products_list (
                          shadow_product_id,
                          sku,
                          vendor_id,
                          deleted_at,
                          master_sku,
                          shop_id,
                          ean,
                          name,
                          product_error_count,
                          match_error_count,
                          dispersal_state,
                          last_synced_at,
                          created_at,
                          updated_at
                        ) SELECT
                          NEW.id,
                          NEW.product_id,
                          NEW.vendor_id,
                          NEW.deleted_at,
                          (
                            SELECT master_sku FROM products
                            WHERE products.sku = NEW.product_id
                              AND products.deleted_at IS NULL
                          ),
                          (
                            SELECT shop_id FROM products
                            WHERE products.sku = NEW.product_id
                              AND products.deleted_at IS NULL
                          ),
                          COALESCE(
                            NEW.ean,
                            (
                              SELECT ean FROM products
                              WHERE products.sku = NEW.product_id
                                AND products.deleted_at IS NULL
                            )
                          ),
                          COALESCE(NEW.name, (SELECT name from products where products.sku = NEW.product_id)),
                          (
                            SELECT count(*) FROM product_errors
                            WHERE product_errors.shadow_product_id = NEW.id
                              AND product_errors.severity = 'error'
                              AND product_errors.deleted_at IS NULL
                          ),
                          (
                            SELECT count(*) FROM vendor_product_matches
                            WHERE vendor_product_matches.product_id = NEW.product_id
                              AND vendor_product_matches.vendor_id = NEW.vendor_id
                              AND vendor_product_matches.matched = FALSE
                              AND vendor_product_matches.deleted_at IS NULL
                          ),
                          (
                            SELECT state FROM dispersals
                            WHERE dispersals.product_id = NEW.product_id
                              AND dispersals.vendor_id = NEW.vendor_id
                              AND dispersals.deleted_at IS NULL
                            ORDER BY dispersals.updated_at DESC
                            LIMIT 1
                          ),
                          (
                            SELECT updated_at FROM dispersals
                            WHERE dispersals.product_id = NEW.product_id
                              AND dispersals.vendor_id = NEW.vendor_id
                              AND dispersals.state = 'completed'
                              AND dispersals.deleted_at IS NULL
                          ),
                          now(),
                          now()
                        WHERE NOT EXISTS (SELECT * FROM upsert);
                      END IF;

                      RETURN NEW;
                    END
                  $$;
    SQL
  end
end
