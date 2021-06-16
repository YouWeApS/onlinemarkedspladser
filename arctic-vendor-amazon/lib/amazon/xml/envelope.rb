# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

module Amazon
  module XML
    module Envelope
      autoload :Base, 'amazon/xml/envelope/base'
      autoload :Products, 'amazon/xml/envelope/products'
      autoload :Inventory, 'amazon/xml/envelope/inventory'
      autoload :Prices, 'amazon/xml/envelope/prices'
      autoload :Relationships, 'amazon/xml/envelope/relationships'
      autoload :Images, 'amazon/xml/envelope/images'
    end
  end
end

# rubocop:enable Style/ClassAndModuleChildren
