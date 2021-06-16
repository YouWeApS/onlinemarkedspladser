# frozen_string_literal: true

class AddPurchasedAtToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :purchased_at, :datetime
    add_index :orders, :purchased_at
  end
end
