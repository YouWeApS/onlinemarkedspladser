module Smartweb::V1
  autoload :API, 'smartweb/v1/api'
  autoload :Order, 'smartweb/v1/order'

  module Workers
    autoload :BaseWorker, 'smartweb/v1/workers/base_worker'

    module Products
      autoload :CollectionWorker, 'smartweb/v1/workers/products/collection_worker'
    end

    module Categories
      autoload :CollectionWorker, 'smartweb/v1/workers/categories/collection_worker'
    end

    module Orders
      autoload :DisperseWorker, 'smartweb/v1/workers/orders/disperse_worker'
      autoload :CollectionWorker, 'smartweb/v1/workers/orders/collection_worker'
    end
  end

  module Formatters
    autoload :FormatProduct, 'smartweb/v1/formatters/format_product'
    autoload :FormatCategory, 'smartweb/v1/formatters/format_category'
    autoload :FormatOrder, 'smartweb/v1/formatters/format_order'
  end
end
