class DontRequireLineIdInOrderLines < ActiveRecord::Migration[5.2]
  def change
    change_column_null :order_lines, :line_id, true
  end
end
