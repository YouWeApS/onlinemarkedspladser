# frozen_string_literal: true

# rubocop:disable Style/AccessModifierDeclarations
# rubocop:disable Style/ClassAndModuleChildren

module Amazon
  module XML
    module ProductData
      autoload :Base, 'amazon/xml/product_data/base'
      autoload :Clothing, 'amazon/xml/product_data/clothing'
      autoload :Beauty, 'amazon/xml/product_data/beauty'
      autoload :Builder, 'amazon/xml/product_data/builder'

      def new(xml_builder, product, **options)
        Builder.new(xml_builder, product, **options).instance
      end

      # TODO: Investigate what's the right use of the module_function, so we
      # don't need to disable the Style/AccessModifierDeclarations cop.
      module_function :new
    end
  end
end

# rubocop:enable Style/AccessModifierDeclarations
# rubocop:enable Style/ClassAndModuleChildren
