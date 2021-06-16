# frozen_string_literal: true

class AddRawDataToProductErrors < ActiveRecord::Migration[5.2]
  def change
    add_column :product_errors, :raw_data, :jsonb
  end
end
