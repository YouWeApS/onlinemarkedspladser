# frozen_string_literal: true

class Account < ApplicationRecord #:nodoc:
  has_many :shops, dependent: :destroy
  has_many :user_accounts, dependent: :destroy
  has_many :users, through: :user_accounts
end
