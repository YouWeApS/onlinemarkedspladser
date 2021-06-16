# frozen_string_literal: true

class RemoveDispersedAtFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :dispersed_at
  end
end
