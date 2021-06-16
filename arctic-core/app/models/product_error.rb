# frozen_string_literal: true

class ProductError < ApplicationRecord #:nodoc:
  belongs_to :shadow_product, touch: true

  validates :message, presence: true

  validates :severity,
    presence: true,
    inclusion: { in: %w[error warning] }
end
