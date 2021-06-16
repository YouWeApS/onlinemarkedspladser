# frozen_string_literal: true

class User < ApplicationRecord #:nodoc:
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks
  has_many :session_tokens
  has_many :user_accounts
  has_many :accounts, through: :user_accounts
  has_many :shops, through: :accounts
  has_many :vendors, through: :shops

  has_one_attached :avatar

  validates :password_confirmation,
    presence: true, if: -> { password.present? }

  has_secure_password

  def self.find_and_authenticate(email, password)
    where(email: email).take!.authenticate(password) ||
      raise(ActiveRecord::RecordNotFound)
  rescue ActiveRecord::RecordNotFound
    raise HttpError::Unauthorized, 'invalid username or password'
  end
end
