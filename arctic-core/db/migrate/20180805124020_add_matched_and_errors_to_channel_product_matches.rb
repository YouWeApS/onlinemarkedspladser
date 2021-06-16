# frozen_string_literal: true

class AddMatchedAndErrorsToChannelProductMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :channel_product_matches, :matched, :boolean, default: true, null: false
    add_column :channel_product_matches, :error, :string

    add_index :channel_product_matches, :matched
  end
end
