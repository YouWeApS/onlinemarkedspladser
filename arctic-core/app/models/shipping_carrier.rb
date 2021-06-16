# frozen_string_literal: true

class ShippingCarrier < ApplicationRecord #:nodoc:
  CARRIERS = %w[
    non_ship
    la_poste
    ups
    gls
    postnord
    bring
    dao
    unknown
  ].freeze

  enum shipping_carrier: CARRIERS
end
