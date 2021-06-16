# frozen_string_literal: true

class CreateUserAccounts < ActiveRecord::Migration[5.2]
  def up
    create_table :user_accounts, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :account_id

      t.timestamps
    end

    add_index :user_accounts, :user_id
    add_index :user_accounts, :account_id

    UserAccount.reset_column_information

    User.find_each do |user|
      UserAccount.create! user: user, account_id: user.account_id
    end

    remove_column :users, :account_id
  end
end
