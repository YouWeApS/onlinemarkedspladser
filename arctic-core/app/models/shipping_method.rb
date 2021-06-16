# frozen_string_literal: true

class ShippingMethod < ApplicationRecord #:nodoc:
  METHODS = %w[
    non_ship
    home
    business
    pickup
    unknown
  ].freeze

  enum shipping_method: METHODS
end
