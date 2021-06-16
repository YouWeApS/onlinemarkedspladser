# frozen_string_literal: true

class V1::Ui::CurrencyBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :decimal_mark, :iso_code, :thousands_separator, :symbol_first, :name, :symbol

  field :example do |c|
    Money.new(123.45, Money::Currency.new(c['id'])).to_s
  end
end
