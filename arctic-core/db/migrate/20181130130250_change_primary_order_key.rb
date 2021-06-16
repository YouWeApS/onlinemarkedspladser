class ChangePrimaryOrderKey < ActiveRecord::Migration[5.2]
  def up
    # Orders
    execute 'ALTER TABLE orders DROP CONSTRAINT orders_pkey;'
    rename_column :orders, :id, :order_id
    add_column :orders, :id, :uuid,
      null: false,
      default: 'public.gen_random_uuid()',
      primary_key: true

    # Order invoices
    execute 'ALTER TABLE order_invoices DROP CONSTRAINT order_invoices_pkey;'
    remove_column :order_invoices, :id
    add_column :order_invoices, :id, :uuid,
      null: false,
      default: 'public.gen_random_uuid()',
      primary_key: true

    # Order lines
    execute 'ALTER TABLE order_lines DROP CONSTRAINT order_lines_pkey;'
    remove_column :order_lines, :id
    add_column :order_lines, :id, :uuid,
      null: false,
      default: 'public.gen_random_uuid()',
      primary_key: true
    rename_column :order_lines, :order_id, :old_order_id
    add_column :order_lines, :order_id, :uuid
  end

  def down
  end
end
