# frozen_string_literal: true

class RawProductData < ApplicationRecord #:nodoc:
  belongs_to :product, touch: true

  scope :current, -> { order(created_at: :desc).last }


  validates :data, presence: true, uniqueness: true
end
