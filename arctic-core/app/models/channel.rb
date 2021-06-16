# frozen_string_literal: true

class Channel < ApplicationRecord #:nodoc:
  validates :name, presence: true
  validates :auth_config_schema, presence: true

  has_many :vendors
end
