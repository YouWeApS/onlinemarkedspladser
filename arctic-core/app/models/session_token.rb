# frozen_string_literal: true

class SessionToken < ApplicationRecord #:nodoc:
  belongs_to :user
end
