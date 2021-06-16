class CreateProductLists < ActiveRecord::Migration[5.2]
  SIMPLE_INDICES = %i[
    deleted_at
    dispersal_state
    ean
    product_error_count
    last_synced_at
    master_sku
    match_error_count
    name
    shadow_product_id
    shop_id
    sku
    vendor_id
  ]

  def up
    create_table :products_list, id: false do |t|
      t.string :sku, null: false
      t.string :name
      t.string :ean
      t.string :dispersal_state
      t.string :master_sku
      t.uuid :vendor_id, null: false
      t.uuid :shop_id, null: false
      t.uuid :shadow_product_id, null: false
      t.integer :match_error_count, null: false, default: 0
      t.integer :product_error_count, null: false, default: 0
      t.datetime :last_synced_at
      t.datetime :deleted_at
      t.timestamps
    end

    SIMPLE_INDICES.each do |i|
      add_index :products_list, i
    end

    add_index :products_list, %i[sku vendor_id shop_id shadow_product_id],
      unique: true,
      name: :unique_identification_group
  end

  def down
    SIMPLE_INDICES.each do |i|
      remove_index :products_list, i
    end

    remove_index :products_list, %i[sku vendor_id shop_id shadow_product_id]

    drop_table :products_list
  end
end
