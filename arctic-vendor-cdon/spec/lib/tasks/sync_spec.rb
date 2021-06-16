require 'spec_helper'

RSpec.describe 'sync:all' do
  include_context :rake
  its(:prerequisites) { should include('sync:v1:all') }
end

RSpec.describe 'sync:v1:all' do
  include_context :rake
  its(:prerequisites) { should include('products:all') }
  its(:prerequisites) { should include('orders:all') }
end

RSpec.describe 'sync:v1:products:disperse' do
  include_context :rake
  include_context :v1_products

  let(:api) { double }

  let(:shop) do
    {
      id: 'shop1',
      config: {
        source_id: 'xxx',
        country: 'dk',
        vat: 25.0,
      },
      auth_config: {
        api_key: 'abcdef123',
      },
    }
  end

  before do
    allow(Arctic::Vendor::Dispersal::API).to receive(:new).and_return api
  end

  it 'collects the shops from Core API' do
    expect(api).to receive(:list_shops)
    subject.invoke
  end

  it 'disperses the products to CDON' do
    expect(api).to receive(:list_shops).and_yield shop.as_json
    expect(api).to receive(:list_products).and_return [product1, product2, product3]
    expect(api).to receive(:synced).with(shop[:id], :products).and_return true

    expect(CDON::V1::Products).to receive(:new)
      .with(shop.as_json, [product1, product2, product3])
      .and_return double(submit: true)

    subject.invoke
  end
end

RSpec.describe 'sync:v1:orders:disperse' do
  include_context :rake

  let(:api) { double }

  let(:shop) do
    {
      id: 'shop1',
      config: {
        source_id: 'xxx',
        country: 'se',
        vat: 25.0,
      },
      auth_config: {
        api_key: '9041c071-145a-42f5-948a-1fe68b8790cf',
      },
    }
  end

  let(:order) do
    {
      id: 'order-1',
      order_id: 'Order1',
      order_lines: [
        {
          id: 'order-line-1',
          line_id: 'line-1',
          track_and_trace_reference: 'abcdef123',
          quantity: 1,
        }
      ],
    }.as_json
  end

  before do
    allow(Arctic::Vendor::Dispersal::API).to receive(:new).and_return api
  end

  describe 'InvalidOrderState' do
    before do
      expect_any_instance_of(CDON::V1::OrderLine)
        .to receive(:deliver!)
        .and_raise(CDON::V1::OrderLine::InvalidOrderState, 'Invoiced')
    end

    it 'raises InvalidOrderState' do
      expect(api).to receive(:list_shops).and_yield shop.as_json
      expect(api).to receive(:last_synced_at).and_return 2.weeks.ago
      expect(api).to receive(:orders).and_return [order]
      expect(api).to receive(:update_order_line).with('shop1', 'order-1', 'order-line-1', { status: "invoiced" })
      subject.invoke
    end
  end
end

RSpec.describe 'sync:v1:orders:collect' do
  include_context :rake

  let(:api) { double }

  let(:shop) do
    {
      id: 'shop1',
      config: {
        source_id: 'xxx',
        country: 'se',
        vat: 25.0,
        report_id: 'd4ea173d-bfbc-48f5-b121-60f1a5d35a34',
      },
      auth_config: {
        api_key: '9041c071-145a-42f5-948a-1fe68b8790cf',
      },
    }
  end

  let(:expected_order) do
    { id: 646_753_046,
      invoices: [
        {
          amount: 10.0,
          currency: 'SEK',
          invoice_id: '1003075',
          order_lines: [1],
          status: 'awaiting_payment',
        },
      ],
      shipping_fee: 0,
      total: 40.0,
      currency: 'SEK',
      order_id: 646753046,
      order_lines: [
        {
          cents_with_vat: 1000.0,
          line_id: 1,
          product_id: 'abcdef123',
          quantity: 1,
          status: 'invoiced',
          track_and_trace_reference: '2:1234',
        },
        {
          cents_with_vat: 1000.0,
          line_id: 2,
          product_id: 'hijklm457',
          quantity: 1,
          status: 'created',
          track_and_trace_reference: nil,
        },
      ],
      purchased_at: '2018-11-23T13:15:05.687',
      raw_data: { 'OrderDetails' =>
        { 'OrderKey' => 'd70a7e53-b2d5-4858-855e-e39086d5601e-646753046',
          'OrderId' => 646_753_046,
          'State' => 'Pending',
          'PaymentStatus' => 'AwaitingPayment',
          'CreatedDateUtc' => '2018-11-23T13:15:05.687',
          'LastModifiedDateUtc' => '2018-11-27T10:39:28.88',
          'MerchantId' => 'd70a7e53-b2d5-4858-855e-e39086d5601e',
          'CountryCode' => 'Sweden',
          'CurrencyCode' => 'SEK',
          'TotalAmount' => 20.0,
          'TotalAmountExcludingVat' => 20.0,
          'TotalSalesAmount' => 40.0,
          'HoursPastDeliverySla' => 0,
          'CustomerInfo' =>
          { 'CustomerId' => 0,
            'EmailAddress' => 'anders@andersson.cdon.com',
            'ShippingAddress' =>
            { 'Name' => 'Anders Andersson',
              'StreetAddress' => 'Din Gata 100 tr 6',
              'CoAddress' => nil,
              'ZipCode' => '201 23',
              'City' => 'Malmö',
              'Country' => 'SE' },
            'BillingAddress' =>
            { 'Name' => 'Anders Andersson',
              'StreetAddress' => 'Din Gata 100 tr 6',
              'CoAddress' => nil,
              'ZipCode' => '201 23',
              'City' => 'Malmö',
              'Country' => 'SE' },
            'Phones' => { 'PhoneMobile' => '', 'PhoneWork' => '', 'PhoneHome' => '' },
            'SocialSecurityNumber' => '' },
          'OrderRows' =>
          [{ 'OrderRowId' => 1,
             'FulfillmentStatus' => 'Invoiced',
             'PaymentStatus' => 'AwaitingPayment',
             'ProductId' => 'abcdef123',
             'ProductName' => 'Product 1',
             'ProductType' => 'Article',
             'Quantity' => 1,
             'DeliveredQuantity' => 1,
             'InvoicedQuantity' => 1,
             'CancelledQuantity' => 0,
             'ReturnedQuantity' => 0,
             'PickedQuantity' => nil,
             'PricePerUnit' => 10.0,
             'OrdinaryPricePerUnit' => 20.0,
             'VatPerUnit' => 0.0,
             'VatPercentage' => 0.0,
             'PackageId' => "1234",
             'PackageCarrierId' => 2,
             'AddonToProductId' => nil,
             'DebitedAmount' => 10.0,
             'CreditedAmount' => 0.0,
             'PaidAmount' => 0.0,
             'RefundedAmount' => 0.0,
             'MerchantCampaignDiscount' => [] },
           { 'OrderRowId' => 2,
             'FulfillmentStatus' => 'Pending',
             'PaymentStatus' => 'NotApplicable',
             'ProductId' => 'hijklm457',
             'ProductName' => 'Product 2',
             'ProductType' => 'Article',
             'Quantity' => 1,
             'DeliveredQuantity' => 0,
             'InvoicedQuantity' => 0,
             'CancelledQuantity' => 0,
             'ReturnedQuantity' => 0,
             'PickedQuantity' => nil,
             'PricePerUnit' => 10.0,
             'OrdinaryPricePerUnit' => 20.0,
             'VatPerUnit' => 0.0,
             'VatPercentage' => 0.0,
             'PackageId' => nil,
             'PackageCarrierId' => nil,
             'AddonToProductId' => nil,
             'DebitedAmount' => 0.0,
             'CreditedAmount' => 0.0,
             'PaidAmount' => 0.0,
             'RefundedAmount' => 0.0,
             'MerchantCampaignDiscount' => [] }],
          'OrderNotices' => [],
          'InvoiceNumbers' => ["1003075"],
          'TotalVat' => 0.0,
          'IsSplitOrder' => false },
          'Invoices' => [
            {
              "BookingDateUtc"=>"2018-11-27T10:39:28.4022715Z",
              "CreatedDateUtc"=>"2018-11-27T10:39:28.4022715Z",
              "CurrencyCode"=>"SEK",
              "CustomerId"=>1,
              "InvoiceNumber"=>"1003075",
              "MerchantId"=>"d70a7e53-b2d5-4858-855e-e39086d5601e",
              "OrderId"=>646753046,
              "Payments"=>nil,
              "Rows"=>
               [{"InvoiceRowNumber"=>1,
                 "OrderRowId"=>1,
                 "PricePerUnit"=>10.0,
                 "ProductId"=>"abcdef123",
                 "ProductName"=>"Product 1",
                 "ProductType"=>"Article",
                 "Quantity"=>1,
                 "Status"=>"AwaitingPayment",
                 "TotalAmount"=>10.0,
                 "TotalCreditNoteAmount"=>0.0,
                 "TotalPaymentAmount"=>0.0,
                 "TotalVat"=>0.0,
                 "VatPerUnit"=>0.0,
                 "VatPercentage"=>0.0}],
              "Status"=>"AwaitingPayment",
              "TotalAmount"=>10.0,
              "TotalVat"=>0.0,
            },
          ],
        },
      billing_address: { name: 'Anders Andersson',
                         address1: 'Din Gata 100 tr 6',
                         address2: nil,
                         city: 'Malmö',
                         zip: '201 23',
                         country: 'SE',
                         email: 'anders@andersson.cdon.com',
                         phone: '' },
      shipping_address: { name: 'Anders Andersson',
                          address1: 'Din Gata 100 tr 6',
                          address2: nil,
                          city: 'Malmö',
                          zip: '201 23',
                          country: 'SE',
                          email: 'anders@andersson.cdon.com',
                          phone: '' } }
  end

  before do
    allow(Arctic::Vendor::Dispersal::API).to receive(:new).and_return api
  end

  it 'collects orders from CDON' do
    Timecop.freeze '2018-11-29' do
      VCR.use_cassette :v1_collect_orders do
        expect(api).to receive(:list_shops).and_yield shop.as_json
        expect(api).to receive(:last_synced_at).and_return 2.weeks.ago
        expect(api).to receive(:create_order).with(shop[:id], expected_order).and_return true
        expect(api).to receive(:collect_invoice).with(shop[:id], expected_order[:id], expected_order[:invoices][0]).and_return true
        expect(api).to receive(:collect_order_line).with(shop[:id], expected_order[:id], expected_order[:order_lines][0]).and_return true
        expect(api).to receive(:collect_order_line).with(shop[:id], expected_order[:id], expected_order[:order_lines][1]).and_return true
        expect(api).to receive(:synced).with(shop[:id], :orders).and_return true

        subject.invoke
      end
    end
  end
end
