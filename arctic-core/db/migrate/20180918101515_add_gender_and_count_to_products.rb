class AddGenderAndCountToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :gender, :string
    add_index :products, :gender

    add_column :products, :count, :string
    add_index :products, :count

    add_column :products, :scent, :string
    add_index :products, :scent

    add_column :shadow_products, :gender, :string
    add_index :shadow_products, :gender

    add_column :shadow_products, :count, :string
    add_index :shadow_products, :count

    add_column :shadow_products, :scent, :string
    add_index :shadow_products, :scent
  end
end
