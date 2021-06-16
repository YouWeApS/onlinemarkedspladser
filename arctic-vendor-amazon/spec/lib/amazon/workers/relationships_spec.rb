require 'spec_helper'

RSpec.describe Amazon::Workers::Relationships, type: :worker do
  let(:instance) { described_class.new }
  let(:shop_id) { '69938c7a-3fc5-4789-9d74-5feb3301b91b' }
  let(:feed_id) { 'e5ea99e4-fd94-454a-b7a1-8263901069b2' }
  let(:options) { {} }
  let(:perform) { instance.perform shop_id, options }
  let(:core_api) { double }
  let(:shop) do
    {
      id: shop_id,
      config: {},
      auth_config: {
        marketplace: 'market1',
      },
    }.as_json
  end
  let(:products) do
    [
      {
        sku: 'abcdef123',
      },
    ].as_json
  end
  let(:submit_response_xml) do
    <<-XML
      <SubmitFeedResponse>
        <SubmitFeedResult>
          <FeedSubmissionInfo>
            <FeedSubmissionId>#{feed_id}</FeedSubmissionId>
          </FeedSubmissionInfo>
        </SubmitFeedResult>
      </SubmitFeedResponse>
    XML
  end
  let(:feed_result_xml) do
    <<-XML
      <AmazonEnvelope>
        <Message>
          <ProcessingReport>
            <Result></Result>
          </ProcessingReport>
        </Message>
      </AmazonEnvelope>
    XML
  end

  before do
    expect(Arctic::Vendor::Dispersal::API).to receive(:new).and_return core_api
    expect(core_api).to receive(:get_shop).with(shop_id).and_return shop
    expect(core_api).to receive(:list_products).with(shop_id).and_return products

    mws_client = double
    expect(MWS::Feeds::Client).to receive(:new).and_return mws_client
    expect(mws_client).to receive(:get_feed_submission_result).with(feed_id).and_return double(body: feed_result_xml)

    expect(Amazon::Workers::ProductState).to receive(:perform_async).with shop_id, 'abcdef123', :inprogress

    response = double body: submit_response_xml
    expect(instance).to receive(:submit_feed).and_return response

    expect(Amazon::Workers::ProductState).to receive(:perform_async).with shop_id, 'abcdef123', :ready
  end

  it "performs correctly" do
    expect(core_api).to receive(:synced).with(shop_id, :products)
    perform
  end

  context 'with continue option' do
    before do
      options[:continue] = true
      expect(Amazon::Workers::Images).to receive(:perform_async).with(shop_id, options)
    end
  end
end
