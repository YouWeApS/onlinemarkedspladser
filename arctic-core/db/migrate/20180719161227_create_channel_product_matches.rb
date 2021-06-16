# frozen_string_literal: true

class CreateChannelProductMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :channel_product_matches, id: :uuid do |t|
      t.string :product_id, null: false
      t.uuid :channel_id, null: false

      t.timestamps
    end

    add_index :channel_product_matches, :product_id
    add_index :channel_product_matches, :channel_id
  end
end
