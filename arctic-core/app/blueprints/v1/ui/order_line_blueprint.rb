# frozen_string_literal: true

class V1::Ui::OrderLineBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :line_id, :status, :quantity

  # rubocop:disable Style/SymbolProc

  field :sku do |ol|
    ol.product_id
  end

  # rubocop:enable Style/SymbolProc

  field :total do |ol|
    Money.new(ol.cents_with_vat, ol.order.currency).format
  end

  field :total_without_vat do |ol|
    Money.new(ol.cents_without_vat, ol.order.currency).format
  end
end
