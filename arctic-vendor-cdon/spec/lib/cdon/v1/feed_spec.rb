require "spec_helper"
require 'vcr'

RSpec.describe CDON::V1::Feed do
  include_context :v1_products

  let(:instance) { CDON::V1::Products.new shop, products }

  let(:shop) do
    {
      config: {
        source_id: 'xxx',
        country: 'se',
        vat: 25.00,
      },

      auth_config: {
        api_key: '9041c071-145a-42f5-948a-1fe68b8790cf',
      },
    }
  end

  describe '#submit' do
    it 'Uploads and starts processing the file' do
      VCR.use_cassette :v1_feed do
        expect(Arctic.logger).to receive(:info).with \
          "POSTed xml file to api/importfile. Import ID: ccfdf28b8b1a454aaa847534b5a52929"

        expect(Arctic.logger).to receive(:info).with \
          "Started processing Import ID: ccfdf28b8b1a454aaa847534b5a52929: File was queued for process."

        instance.submit
      end
    end
  end
end
