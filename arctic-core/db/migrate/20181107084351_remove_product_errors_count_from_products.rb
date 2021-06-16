class RemoveProductErrorsCountFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :product_errors_count, :integer
  end
end
