# frozen_string_literal: true

require 'dotenv'
Dotenv.load

require 'bundler/setup'
Bundler.require :default, ENV.fetch('RACK_ENV', 'development')

require 'rollbar'
Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.environment = ENV.fetch 'RACK_ENV', 'development'
  config.host = ENV.fetch 'HOST', 'amazon'
end

$LOAD_PATH.unshift File.expand_path __dir__

require 'amazon/xml'
require 'amazon/sidekiq_setup'
require 'amazon/validator'
require 'amazon/logger'

module Amazon
  autoload :Archive, 'amazon/archive'
  autoload :Credentials, 'amazon/credentials'
  autoload :ShippingMapping, 'amazon/shipping_mapping'

  module Formatters
    autoload :Order, 'amazon/formatters/order'
  end

  module Workers
    autoload :Base, 'amazon/workers/base'
    autoload :Images, 'amazon/workers/images'
    autoload :Inventory, 'amazon/workers/inventory'
    autoload :Prices, 'amazon/workers/prices'
    autoload :ProductError, 'amazon/workers/product_error'
    autoload :Products, 'amazon/workers/products'
    autoload :ProductState, 'amazon/workers/product_state'
    autoload :Relationships, 'amazon/workers/relationships'
  end
end
