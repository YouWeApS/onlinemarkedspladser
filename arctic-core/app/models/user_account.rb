# frozen_string_literal: true

class UserAccount < ApplicationRecord #:nodoc:
  belongs_to :user
  belongs_to :account
end
