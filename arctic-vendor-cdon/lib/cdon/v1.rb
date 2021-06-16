# frozen_string_literal: true

require_relative '../cdon'

date_formats = {
  xml_date: '%Y-%m-%dT%H:%M:%S',
}

Time::DATE_FORMATS.merge! date_formats
Date::DATE_FORMATS.merge! date_formats

module CDON::V1
  autoload :API, 'cdon/v1/api'
  autoload :Schema, 'cdon/v1/schema'
  autoload :Feed, 'cdon/v1/feed'
  autoload :Products, 'cdon/v1/products'
  autoload :Validator, 'cdon/v1/validator'
  autoload :Order, 'cdon/v1/order'
  autoload :OrderLine, 'cdon/v1/order_line'
  autoload :OrderFormatter, 'cdon/v1/order_formatter'
end
