class AddUniqIndexToUserAccount < ActiveRecord::Migration[5.2]
  def up
    duplicated_user_accounts = UserAccount.unscoped{ UserAccount.select(:account_id, :user_id)
                                                         .group(:account_id, :user_id)
                                                         .having("count(*) > 1")}

    duplicated_user_accounts.each do |user_accounts|
      UserAccount.unscoped.where(account_id: user_accounts.account_id, user_id: user_accounts.user_id).take.really_destroy!
    end

    add_index :user_accounts, [:user_id, :account_id], unique: true
  end

  def down
    remove_index :user_accounts, column: [:user_id, :account_id]
  end
end
