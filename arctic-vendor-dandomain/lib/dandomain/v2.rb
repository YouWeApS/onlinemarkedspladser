module Dandomain::V2
  autoload :API, 'dandomain/v2/api'
  autoload :Format, 'dandomain/v2/format'
  autoload :Customer, 'dandomain/v2/customer'
  autoload :Order, 'dandomain/v2/order'
  autoload :ShippingMapping, 'dandomain/v2/shipping_mapping'

  module Workers
    module Products
      autoload :CollectionWorker, 'dandomain/v2/workers/products/collection_worker'
    end
  end
end
