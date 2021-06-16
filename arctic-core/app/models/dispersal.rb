# frozen_string_literal: true

class Dispersal < ApplicationRecord #:nodoc:
  STATES = %w[pending inprogress completed failed].freeze

  belongs_to :vendor_shop_configuration
  belongs_to :product, touch: true

  delegate :vendor, to: :vendor_shop_configuration

  scope :with_state, ->(*states) { where state: states }
  scope :incomplete, -> { with_state(:pending, :inprogress, :failed) }
end
