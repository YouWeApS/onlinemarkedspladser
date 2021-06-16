# frozen_string_literal: true

class ShippingConfiguration < ApplicationRecord #:nodoc:
  belongs_to :vendor_shop_configuration
  belongs_to :shipping_method
  belongs_to :shipping_carrier
end
