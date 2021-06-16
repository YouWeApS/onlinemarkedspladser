# frozen_string_literal: true

require 'dotenv'
Dotenv.load

require 'bundler/setup'
Bundler.require :default, ENV.fetch('RACK_ENV', 'development')

$LOAD_PATH.unshift File.expand_path __dir__

require_relative '../config/sidekiq'
require 'mirakl/validator'

module Mirakl
  autoload :Api, 'mirakl/api'

  module Workers
    autoload :Base, 'mirakl/workers/base'

    module Products
      autoload :Collection, 'mirakl/workers/products/collection'
    end

    module Orders
      autoload :Collection, 'mirakl/workers/orders/collection'
      autoload :VendorUpdate, 'mirakl/workers/orders/vendor_update'
    end
  end

  module Helpers
    autoload :ProductCodeHelper, 'mirakl/helpers/product_code_helper'
    autoload :OfferCodeHelper, 'mirakl/helpers/offer_code_helper'
    autoload :ProductDataHelper, 'mirakl/helpers/product_data_helper'
  end

  module Formatters
    autoload :Order, 'mirakl/formatters/order'
  end

  module Services
    autoload :Archive, 'mirakl/services/archive'
    autoload :ShippingMapping, 'mirakl/services/shipping_mapping'
  end

  module XML
    autoload :Builder, 'mirakl/xml/builder'

    module Product
      autoload :Builder, 'mirakl/xml/product/builder'
      autoload :SkinTreatment, 'mirakl/xml/product/skin_treatment'
    end

    module Offer
      autoload :Builder, 'mirakl/xml/offer/builder'
    end
  end
end
