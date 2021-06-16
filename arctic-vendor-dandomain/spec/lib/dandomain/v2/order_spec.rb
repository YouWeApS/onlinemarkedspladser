require "spec_helper"

RSpec.describe Dandomain::V2::Order, :vcr do
  let(:instance) { described_class.new shop, customer, data }

  let(:customer) do
    double id: '1'
  end

  include_context :shop

  let(:data) do
    {
      id: SecureRandom.uuid,
      order_id: '1',
      status: :created,
      total: '123.45',
      currency: 'DKK',
      vendor_id: 'c09d2fbc-eee6-4f43-aab3-9c0b48325214',
      billing_address: {
        name: "Ute Walker III",
        address1: "620 Eric Flats",
        address2: "Suite 192",
        zip: "45347-6378",
        city: "DuBuqueton",
        country: "DK",
        phone: "1-686-758-3641",
        email: "bob@email.com",
      },
      shipping_address: {
        name: "Ute Walker III",
        address1: "620 Eric Flats",
        address2: "Suite 192",
        zip: "45347-6378",
        city: "DuBuqueton",
        country: "DK",
        phone: "1-686-758-3641",
        email: "bob@email.com",
      },
      order_lines: [
        {
          id: 'cc445caf-bcc1-4b4e-8113-0865bf2bfba6',
          quantity: 1,
          product_id: '9788771613018',
          status: :created,
        },
      ],
    }
  end

  let(:formatted_data) do
    {
      currencyCode: "DKK",
      customerId: '1',
      deliveryInfo: {
        address: '620 Eric Flats',
        address2: 'Suite 192',
        city: 'DuBuqueton',
        country: 'Danmark',
        email: 'bob@email.com',
        name: 'Ute Walker III',
        phone: '1-686-758-3641',
        zipCode: '45347-6378',
      },
      id: nil,
      referenceNumber: '1',
      orderlines: [
        {
          productNumber: :BU_18084,
          quantity: 1,
        },
      ],
      paymentMethodId: 59,
      orderStateId: nil,
      shippingMethodId: 48,
      siteID: 26,
    }.as_json
  end

  subject { instance }

  its(:data) { is_expected.to eql formatted_data }
  its(:shop) { is_expected.to eql shop.as_json }
  its(:api) { is_expected.to be_a Dandomain::V2::API }

  describe '#save' do
    it 'creates the order in DD' do
      skip "Pending resolution of http://bit.ly/2BdUaDS"
      expect(instance.save).to be_present
    end
  end
end
