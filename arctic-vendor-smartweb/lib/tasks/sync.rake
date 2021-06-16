namespace :sync do
  namespace :v1 do
    namespace :products do
      desc 'Collect products from Vendor -> Core'
      task :collect do
        Arctic::Vendor::API.new.list_shops(:collection) do |shop|
          Smartweb::V1::Workers::Products::CollectionWorker.perform_async shop['id']
        end
      end
    end

    namespace :categories do
      desc 'Collect categories from Vendor -> Core'
      task :collect do
        Arctic::Vendor::API.new.list_shops(:collection) do |shop|
          Smartweb::V1::Workers::Categories::CollectionWorker.perform_async shop.fetch('id')
        end
      end
    end

    namespace :orders do
      desc 'Disperse orders from Core -> Vendor'
      task :disperse do
        Arctic::Vendor::API.new.list_shops(:collection) do |shop|
          Smartweb::V1::Workers::Orders::DisperseWorker.perform_async shop.fetch('id')
        end
      end

      desc 'Collect orders from Vendor -> Core'
      task :collect do
        Arctic::Vendor::API.new.list_shops(:collection) do |shop|
          Smartweb::V1::Workers::Orders::CollectionWorker.perform_async shop.fetch('id')
        end
      end
    end
  end
end
