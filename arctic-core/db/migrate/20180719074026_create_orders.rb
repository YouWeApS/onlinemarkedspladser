# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders, id: :uuid do |t|
      t.uuid :shop_id, null: false
      t.string :channel_reference, null: false
      t.string :track_and_trace_reference
      t.uuid :delivery_address_id, null: false
      t.uuid :billing_address_id, null: false
      t.string :status, null: false, default: :created
      t.timestamps
    end

    add_monetize :orders, :total

    add_index :orders, :billing_address_id
    add_index :orders, :channel_reference, unique: true
    add_index :orders, :delivery_address_id
    add_index :orders, :shop_id
    add_index :orders, :status
    add_index :orders, :total_cents
    add_index :orders, :total_currency
    add_index :orders, :track_and_trace_reference
  end
end
