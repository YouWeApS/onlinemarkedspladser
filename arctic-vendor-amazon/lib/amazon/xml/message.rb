# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

module Amazon
  module XML
    module Message
      autoload :Base, 'amazon/xml/message/base'
      autoload :Product, 'amazon/xml/message/product'
      autoload :Inventory, 'amazon/xml/message/inventory'
      autoload :Price, 'amazon/xml/message/price'
      autoload :Relationship, 'amazon/xml/message/relationship'
      autoload :Image, 'amazon/xml/message/image'
    end
  end
end

# rubocop:enable Style/ClassAndModuleChildren
