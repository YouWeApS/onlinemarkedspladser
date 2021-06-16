class LimitShadowProductDescriptionLength < ActiveRecord::Migration[5.2]
  def change
    change_column :shadow_products, :description, :string, limit: 2000
  end
end
