# frozen_string_literal: true

class AddSeverityToErrors < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE TYPE product_error_severity AS ENUM ('error', 'warning');
    SQL

    add_column :product_errors, :severity, :product_error_severity, default: 'error', null: false

    add_index :product_errors, :severity
  end

  def down
    remove_index :product_errors, :severity

    remove_column :product_errors, :severity

    ActiveRecord::Base.connection.execute <<~SQL
      DROP TYPE product_error_severity;
    SQL
  end
end
