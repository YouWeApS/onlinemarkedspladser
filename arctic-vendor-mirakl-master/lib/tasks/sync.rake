# frozen_string_literal: true

require_relative '../mirakl.rb'

namespace :sync do
  namespace :products do
    desc 'Send products to Mirakl'
    task :collect do
      core_api.list_shops(:dispersal) do |shop|
        Mirakl::Workers::Products::Collection.perform_async shop['id']
      end
    end
  end

  namespace :orders do
    desc 'Collect orders from Mirakl to Core'
    task :collect do
      core_api.list_shops(:dispersal) do |shop|
        Mirakl::Workers::Orders::Collection.perform_async shop['id']
      end
    end

    desc 'Update orders on Mirakl'
    task :vendor_update do
      core_api.list_shops(:dispersal) do |shop|
        Mirakl::Workers::Orders::VendorUpdate.perform_async shop['id']
      end
    end
  end

  def core_api
    @core_api ||= Arctic::Vendor::Dispersal::API.new
  end
end
