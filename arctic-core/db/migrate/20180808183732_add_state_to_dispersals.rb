# frozen_string_literal: true

class AddStateToDispersals < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE dispersal_states AS ENUM ('pending', 'inprogress', 'completed', 'failed');
    SQL

    add_column :dispersals, :state, :dispersal_states, null: false, default: :pending
    add_index :dispersals, :state
  end

  def down
    remove_index :dispersals, :state
    remove_column :dispersals, :state

    execute <<-SQL
      DROP TYPE dispersal_states;
    SQL
  end
end
