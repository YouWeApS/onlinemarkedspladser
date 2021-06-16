class ChangeOrderLineStatusToEnum < ActiveRecord::Migration[5.2]
  def change
    remove_column :order_lines, :status
    add_column :order_lines, :status, :integer, default: 0, null: false
  end
end
