# frozen_string_literal: true

class Address < ApplicationRecord #:nodoc:
  validates :name, presence: true
  validates :address1, presence: true
  validates :city, presence: true
  validates :zip, presence: true
  validates :email, presence: true

  def country=(string)
    country = ISO3166::Country.new(string.to_s.upcase) || ISO3166::Country.find_country_by_name(string.to_s.upcase)
    super country.alpha2
  end

  def country
    ISO3166::Country.new super
  end
end
