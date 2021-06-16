# frozen_string_literal: true

class ProductPrice < ApplicationRecord #:nodoc:
  self.inheritance_column = :_type_disabled

  validates :cents, presence: true
  validates :currency, presence: true

  monetize :cents,
    as: :price,
    with_model_currency: :currency

  scope :current, -> { where 'expires_at > now() or expires_at is null' }
  default_scope -> { current }
end
