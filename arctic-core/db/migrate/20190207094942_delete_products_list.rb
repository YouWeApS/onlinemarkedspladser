class DeleteProductsList < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DROP TRIGGER IF EXISTS dispersals_updated_trigger on dispersals;
      DROP TRIGGER IF EXISTS product_errors_updated_trigger on product_errors;
      DROP TRIGGER IF EXISTS products_updated_trigger on products;
      DROP TRIGGER IF EXISTS shadow_products_updated_trigger on shadow_products;
      DROP TRIGGER IF EXISTS vendor_product_matches_updated_trigger on vendor_product_matches;

      DROP FUNCTION IF EXISTS dispersals_updated_function;
      DROP FUNCTION IF EXISTS product_errors_updated_function;
      DROP FUNCTION IF EXISTS products_updated_function;
      DROP FUNCTION IF EXISTS shadow_products_updated_function;
      DROP FUNCTION IF EXISTS vendor_product_matches_updated_function;
    SQL

    drop_table :products_list
  end
end
