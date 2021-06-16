module Economic::V1
  autoload :API, 'economic/v1/api'
  autoload :Order, 'economic/v1/order'
  autoload :Customer, 'economic/v1/customer'
  autoload :Product, 'economic/v1/product'
  autoload :ShippingMapping, 'economic/v1/shipping_mapping'

  module Workers
    autoload :BaseWorker, 'economic/v1/workers/base_worker'

    module Orders
      autoload :DisperseWorker, 'economic/v1/workers/orders/disperse_worker'
    end
  end
end
