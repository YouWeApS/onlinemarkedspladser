# frozen_string_literal: true

class V1::Vendors::ProductPriceBlueprint < Blueprinter::Base
  field :currency do |pp, options|
    ProductPriceExchange.new(pp, options).price.currency.iso_code
  end

  field :expires_at do |o|
    o.expires_at&.strftime DATE_FORMAT
  end

  field :cents do |pp, options|
    ProductPriceExchange.new(pp, options).price.cents
  end
end
