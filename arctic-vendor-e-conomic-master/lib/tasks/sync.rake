namespace :sync do
  namespace :v1 do
    namespace :orders do
      task all: %i[disperse]

      desc 'Disperse orders Core API -> e-conomic'
      task :disperse do
        Arctic::Vendor::Collection::API.new.list_shops(:collection) do |shop|
          Economic::V1::Workers::Orders::DisperseWorker.perform_async shop.fetch('id')
        end
      end
    end
  end
end
