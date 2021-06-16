# frozen_string_literal: true

class AddShipping < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_configurations, id: :uuid do |t|
      t.string :vendor_method
      t.string :vendor_carrier
      t.uuid :shipping_method_id
      t.uuid :shipping_carrier_id
      t.uuid :vendor_shop_configuration_id, index: true

      t.timestamps
    end

    create_table :shipping_methods, id: :uuid do |t|
      t.string :name, null: false
      t.integer :shipping_method, null: false

      t.timestamps
    end

    create_table :shipping_carriers, id: :uuid do |t|
      t.string :name, null: false
      t.integer :shipping_carrier, null: false

      t.timestamps
    end

    add_column :orders, :shipping_method_id, :uuid
    add_column :orders, :shipping_carrier_id, :uuid
  end
end
