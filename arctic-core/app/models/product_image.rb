# frozen_string_literal: true

class ProductImage < ApplicationRecord #:nodoc:
  belongs_to :product, touch: true

  acts_as_list scope: :product

  validates :position, presence: true
  validates :url, presence: true

  scope :sort_by_position, -> { order(position: :asc) }
  default_scope -> { sort_by_position }
end
