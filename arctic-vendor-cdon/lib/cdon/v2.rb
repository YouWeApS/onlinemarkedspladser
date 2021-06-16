# frozen_string_literal: true

require_relative '../cdon'

module CDON::V2
  autoload :Connection, 'cdon/v2/connection'
  autoload :Products, 'cdon/v2/products'
  autoload :ProductBuilder, 'cdon/v2/product_builder'
  autoload :Feed, 'cdon/v2/feed'
end
