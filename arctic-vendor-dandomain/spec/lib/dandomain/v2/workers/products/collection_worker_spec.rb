# require "spec_helper"

# RSpec.describe Dandomain::V2::Workers::Products::CollectionWorker do
#   let(:instance) { described_class.new }

#   describe '#perform' do
#     subject { instance.perform shop_id }
#     let(:shop_id) { 'b4e3e242-36c1-4437-a99a-7ec0ef30d301' }

#     it 'creates each of the products in the Core API' do
#       api = instance.send :core_api
#       expect(instance).to receive(:last_synced_at).at_least(:once).and_return nil

#       VCR.use_cassette 'collection_worker' do
#         expect(api).to receive(:create_product).exactly(9).times
#         subject
#       end
#     end

#     it 'marks the shop as synced' do
#       api = instance.send :core_api
#       expect(instance).to receive(:last_synced_at).at_least(:once).and_return nil

#       VCR.use_cassette 'collection_worker' do
#         expect(api).to receive(:synced).with(shop_id, :products)
#         subject
#       end
#     end
#   end
# end
