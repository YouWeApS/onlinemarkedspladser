require "spec_helper"

RSpec.describe CDON::V1::Schema do
  let(:instance) { described_class.new xml }
  let(:xml) { File.read 'spec/fixtures/v1/products.xml' }

  before { instance.valid? }

  subject { instance }

  its(:valid?) { is_expected.to be_truthy }
  its(:errors) { is_expected.to be_empty }

  context 'invalid xml' do
    let(:xml) { File.read 'spec/fixtures/v1/invalid_products.xml' }
    let(:error) do
      "13:0: ERROR: Element '{http://schemas.cdon.com/product/2.0/shopping-mall.xsd}gtin': This element is not expected. Expected is ( {http://schemas.cdon.com/product/2.0/shopping-mall.xsd}class )."
    end

    its(:valid?) { is_expected.to be_falsey }
    its(:errors) { is_expected.to include error }
  end
end
