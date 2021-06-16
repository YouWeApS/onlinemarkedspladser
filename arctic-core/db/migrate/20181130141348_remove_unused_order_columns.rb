class RemoveUnusedOrderColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :track_and_trace_reference, :string
  end
end
