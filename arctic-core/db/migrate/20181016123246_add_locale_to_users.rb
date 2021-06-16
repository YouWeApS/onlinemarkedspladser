class AddLocaleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :locale, :string, default: :en, null: false
    add_index :users, :locale
  end
end
