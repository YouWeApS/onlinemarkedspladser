require "spec_helper"

RSpec.describe Dandomain::V2::Customer, vcr: { record: :once, match_requests_on: %i[method] } do
  include_context :shop

  let(:instance) { described_class.new(shop, order) }

  let(:order) do
    { 'id' => 'fe869298-f50a-4ddc-af4f-d98df460f171',
      'billing_address' =>
      { 'id' => '6f619e97-d0f3-4f22-86c0-ea4682cd0b25',
        'address1' => "PASSATGE INTERIOR LA PORTALÃ\u0080, 1, 5Âº-D",
        'address2' => nil,
        'city' => 'ALCOY',
        'country' => 'ES',
        'email' => 'wrmqqxtlynjf6kg@marketplace.amazon.es',
        'name' => "MÃ\u008DRIAM FAES BELLVER",
        'phone' => nil,
        'region' => nil,
        'zip' => '03802' },
      'currency' => 'EUR',
      'order_id' => '404-8432968-9937901',
      'order_lines' =>
      [{ 'id' => 'fab9cfa1-0d2c-4630-bcd4-01a758719d2a',
         'cents_with_vat' => 1248,
         'cents_without_vat' => nil,
         'line_id' => nil,
         'product_id' => '197963',
         'quantity' => 1,
         'status' => 'created',
         'track_and_trace_reference' => nil }],
      'payment_fee' => '0.00',
      'payment_reference' => nil,
      'purchased_at' => 'Fri, 22 Feb 2019 13:16:31 UTC',
      'receipt_id' => nil,
      'shipping_address' =>
      { 'id' => '6f619e97-d0f3-4f22-86c0-ea4682cd0b25',
        'address1' => "PASSATGE INTERIOR LA PORTALÃ\u0080, 1, 5Âº-D",
        'address2' => nil,
        'city' => 'ALCOY',
        'country' => 'ES',
        'email' => 'wrmqqxtlynjf6kg@marketplace.amazon.es',
        'name' => "MÃ\u008DRIAM FAES BELLVER",
        'phone' => nil,
        'region' => nil,
        'zip' => '03802' },
      'shipping_fee' => '0.00',
      'status' => ['created'],
      'total' => '12.48',
      'total_without_vat' => '0.00',
      'vat' => 25.0,
      'vendor_id' => '9f529342-474c-48b8-94b3-0a2eb14b54fd' }
  end

  let(:expected_json) do
    {
      "companyName": "",
      "comments": "",
      "cvr": "",
      "ean": "",
      "addressInformation": {
        "address"=>"PASSATGE INTERIOR LA PORTALÃ\u0080, 1, 5Âº-D",
        "address2"=>"",
        "city"=>"ALCOY",
        "country"=>{"id"=>0},
        "name"=>"MÃ\u008DRIAM FAES BELLVER",
        "state"=>"",
        "zipCode"=>"03802",
      },
      "reservedFields": {
        "reservedField1": "",
        "reservedField2": "",
        "reservedField3": "",
        "reservedField4": "",
        "reservedField5": ""
      },
      "customerTypeEnum": "PRIVATE",
      "contactDetails" => {
        "email"=>"wrmqqxtlynjf6kg@marketplace.amazon.es",
        "fax"=>"",
        "phone"=>"",
      },
    }.as_json
  end

  it 'looks up the customer when initialized' do
    expect_any_instance_of(Dandomain::V2::API)
      .to receive(:lookup_customer)
      .with(email: "wrmqqxtlynjf6kg@marketplace.amazon.es")
      .and_return [[], nil]

    instance
  end

  describe '#customer' do
    subject { instance.customer }
    it { is_expected.to eql expected_json }
  end

  context 'existing customer' do
    let(:existing_customer) do
      {
        id: '1234',
      }
    end

    before do
      expect_any_instance_of(Dandomain::V2::API)
        .to receive(:lookup_customer)
        .with(email: "wrmqqxtlynjf6kg@marketplace.amazon.es")
        .and_return [[existing_customer], nil]
    end

    describe '#customer' do
      before { expected_json.merge! "id" => "1234" }
      subject { instance.customer }
      it { is_expected.to eql expected_json }
    end
  end

  describe '#save' do
    it 'check customer validation' do
      instance.customer['addressInformation']['country']['id'] = 1
      expect(instance.country_valid?).to eq(true)
      instance.customer['addressInformation']['country']['id'] = 0
      expect(instance.country_valid?).to eq(false)
    end

    it 'saves the customer' do
      expect_any_instance_of(Dandomain::V2::API).to receive(:create_customer).with(expected_json)
      instance.save
    end

    context 'existing customer' do
      let(:existing_customer) do
        {
          id: '1234',
        }
      end

      before do
        expect_any_instance_of(Dandomain::V2::API)
          .to receive(:lookup_customer)
          .with(email: "wrmqqxtlynjf6kg@marketplace.amazon.es")
          .and_return [[existing_customer], nil]
      end

      xit 'saves the customer' do
        expected_json['id'] = '1234'
        expect_any_instance_of(Dandomain::V2::API).to receive(:update_customer).with(expected_json)
        instance.save
      end
    end
  end
end
