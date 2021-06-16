# frozen_string_literal: true

#
# Maps a value from the source JSON to a product characteristic in Core API.
#
# `from` is either the Ruby #dig path to the characteristic if it's in the
# product json directly, or the name of an associated variation selection (this
# is up to the vendor to implement)
#
# `to` is the Product::CHARACTERISTICS name that the value should map to.
#
class ImportMap < ApplicationRecord
  belongs_to :vendor_shop_configuration, touch: true

  validates :from, presence: true
  validates :to, presence: true
end
