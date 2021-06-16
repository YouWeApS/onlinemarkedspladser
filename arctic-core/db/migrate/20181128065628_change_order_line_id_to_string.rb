class ChangeOrderLineIdToString < ActiveRecord::Migration[5.2]
  def change
    change_column :order_lines, :order_id, :string
  end
end
