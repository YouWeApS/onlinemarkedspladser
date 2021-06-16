require "spec_helper"

RSpec.describe Amazon::XML::ProductData::Base do
  include_context :product_data_instance

  it_behaves_like :product_data_base

  describe '#build_xml' do
    subject { instance.build_xml }
    it { expect { subject }.to raise_error NotImplementedError,
      'must be implemented by descendent' }
  end

  describe '#validator_schema_name' do
    subject { instance.validator_schema_name }
    it { expect { subject }.to raise_error NotImplementedError,
      'must be implemented by descendent' }
  end

  describe '#mapped_value' do
    subject { instance.mapped_value 'sku' }
    it { is_expected.to eql product.fetch(:sku) }

    context 'supply import_map' do
      before do
        options.merge! import_map: {
          'from' => 'sku',
          to: 'ean',
        }
      end

      it { is_expected.to eql product.fetch(:ean) }
    end
  end
end
