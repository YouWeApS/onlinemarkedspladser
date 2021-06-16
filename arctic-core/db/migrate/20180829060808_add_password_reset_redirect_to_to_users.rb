# frozen_string_literal: true

class AddPasswordResetRedirectToToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_reset_redirect_to, :string
  end
end
