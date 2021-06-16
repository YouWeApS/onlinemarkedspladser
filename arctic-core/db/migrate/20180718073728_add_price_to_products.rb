# frozen_string_literal: true

class AddPriceToProducts < ActiveRecord::Migration[5.2]
  def change
    add_monetize :products, :price
    add_index :products, :price_cents
    add_index :products, :price_currency
  end
end
