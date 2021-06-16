require "rails_helper"

RSpec.describe PrivateCurrencyExchange do
  let(:instance) { described_class.new shop }
  let(:shop) { create :shop, :with_currency_conversions }

  describe '#add_rate' do
    subject { instance.add_rate '123' }
    it { expect { subject }.to raise_error NotImplementedError }
  end

  describe '#get_rate' do
    subject { instance.get_rate 'DKK', 'GBP' }
    it { is_expected.to eql 1.0 }
  end
end
