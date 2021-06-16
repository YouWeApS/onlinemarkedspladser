require "spec_helper"

RSpec.describe "sync:all" do
  include_context :rake
  its(:prerequisites) { should include('products') }
end

RSpec.describe "sync:products" do
  include_context :rake
  include_context :sync_setup

  it "schedules the Amazon::Worker::Products worker" do
    VCR.use_cassette("sync_products") do
      expect(Amazon::Workers::Products).to receive(:perform_async).with shop1.as_json['id'], continue: true
      subject.invoke
    end
  end
end

RSpec.describe "sync:inventory" do
  include_context :rake
  include_context :sync_setup

  it "schedules the Amazon::Workers::Inventory worker" do
    VCR.use_cassette("sync_inventory") do
      expect(Amazon::Workers::Inventory).to receive(:perform_async)
        .with shop1.as_json['id'], ignore_errors: true
      subject.invoke
    end
  end
end

RSpec.describe "sync:orders" do
  include_context :rake
  include_context :sync_setup

  let(:credentials1) do
    {
      merchant_id: 'A2IZEMSP8MNSVK',
      auth_token: 'amzn.mws.e4b41780-4aab-f06c-f2c8-a26fa022ba46',
      marketplace: 'A1PA6795UKMFR9',
    }.as_json
  end

  # it "syncs the orders from Amazon -> Core API" do
  #   VCR.use_cassette("sync_orders") do
  #     # It correctly extracts credentials from the shop instances
  #     # This also ensures that we have the right shops
  #     expect(Amazon::Credentials).to receive(:parse).with(shop1.as_json['auth_config']).and_return credentials1

  #     subject.invoke
  #   end
  # end
end
