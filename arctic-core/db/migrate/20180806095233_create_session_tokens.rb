# frozen_string_literal: true

class CreateSessionTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :session_tokens, id: :uuid do |t|
      t.uuid :user_id
      t.timestamps
    end

    add_index :session_tokens, :user_id
  end
end
