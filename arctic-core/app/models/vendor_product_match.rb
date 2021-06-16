# frozen_string_literal: true

class VendorProductMatch < ApplicationRecord #:nodoc:
  belongs_to :product
  belongs_to :vendor_shop_configuration

  delegate :vendor, to: :vendor_shop_configuration

  scope :matched, -> { where(matched: true) }
  scope :unmatched, -> { where(matched: false) }
end
