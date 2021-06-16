# frozen_string_literal: true

class CreateCurrencyConversions < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_conversions, id: :uuid do |t|
      t.uuid :shop_id, null: false
      t.string :from_currency, null: false
      t.string :to_currency, null: false
      t.float :rate, null: false

      t.timestamps
    end

    add_index :currency_conversions, :shop_id
    add_index :currency_conversions, :from_currency
    add_index :currency_conversions, :to_currency
    add_index :currency_conversions, :rate
  end
end
