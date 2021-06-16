class RemoveTotalFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :total_cents, :integer
  end
end
