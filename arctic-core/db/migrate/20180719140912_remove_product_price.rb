# frozen_string_literal: true

class RemoveProductPrice < ActiveRecord::Migration[5.2]
  def change
    remove_index :products, :price_cents
    remove_index :products, :price_currency
    remove_column :products, :price_cents
    remove_column :products, :price_currency
  end
end
