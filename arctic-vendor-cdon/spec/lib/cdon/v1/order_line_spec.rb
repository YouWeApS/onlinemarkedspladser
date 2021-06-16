require "spec_helper"
require "webmock/rspec"

RSpec.describe CDON::V1::OrderLine do
  let(:instance) { described_class.new shop, attributes, '1' }

  let(:shop) do
    {
      id: 'shop1',
      auth_config: {
        api_key: 'hijklm456',
      },
    }
  end

  let(:attributes) do
    {
      order_id: 'Order1',
      line_id: '1',
      quantity: 1,
      track_and_trace_reference: 'abcdef123',
    }
  end

  subject { instance }

  its(:attributes) { is_expected.to eql attributes.as_json }

  describe '#deliver!' do
    let(:order) do
      {
        OrderDetails: {
          Orderid: 'Order1',
          State: 'Pending',
          OrderRows: [
            {
              ProductName: "Something",
              OrderRowId: "1",
              QuantityToDeliver: "1",
              PackageId: nil,
            },
            {
              ProductId: 'Postage',
              ProductName: "Postage",
              OrderRowId: "2",
              QuantityToDeliver: "1",
              PackageId: nil,
            },
          ],
        },
      }.as_json
    end

    before { expect(instance).to receive(:order).at_least(:once).and_return order }

    let(:expected_json) do
      {
        OrderId: "1",
        Products: [
          {
            OrderRowId: "1",
            QuantityToDeliver: 1,
            PackageId: "abcdef123",
          },
          {
            OrderRowId: "2",
            QuantityToDeliver: 1,
            PackageId: "abcdef123",
          },
        ],
      }.to_json
    end

    it 'post correct values' do
      VCR.use_cassette :order_line_correct do
        expect(instance.deliver!).to be_truthy
        assert_requested(:post, "https://integration-admin.marketplace.cdon.com/api/orderdelivery",
                         body: expected_json,
                         times: 1)
      end
    end

    it 'post incorrect values' do
      VCR.use_cassette :order_line_not_correct do
        msg = <<~MSG
          Unable to mark order line (1) for order 1 as delivered.
          Response body is: TEST ERROR
        MSG
        expect{ instance.deliver! }.to raise_error(StandardError, msg)
        assert_requested(:post, "https://integration-admin.marketplace.cdon.com/api/orderdelivery",
                         body: expected_json,
                        times: 1)
      end
    end
  end
end
