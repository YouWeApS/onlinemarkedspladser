require "rails_helper"

RSpec.describe String do
  describe '#number?' do
    subject { string.number? }

    context 'float as string' do
      let(:string) { '1.2' }
      it { is_expected.to be_truthy }
    end

    context 'integer as string' do
      let(:string) { '1' }
      it { is_expected.to be_truthy }
    end

    context 'string containing integer' do
      let(:string) { '1 one' }
      it { is_expected.to be_falsey }
    end

    context 'float containing integer' do
      let(:string) { '1.2 one' }
      it { is_expected.to be_falsey }
    end
  end
end
