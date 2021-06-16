# frozen_string_literal: true

class CurrencyConversion < ApplicationRecord #:nodoc:
  belongs_to :shop

  validates :from_currency, presence: true
  validates :to_currency, presence: true
  validates :rate, presence: true, numericality: true

  def from_currency=(currency)
    super currency.to_s.upcase
  end

  def to_currency=(currency)
    super currency.to_s.upcase
  end
end
