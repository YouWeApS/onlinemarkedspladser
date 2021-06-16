# frozen_string_literal: true

class V1::Vendors::CurrencyConversionBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :from_currency, :to_currency, :rate
end
