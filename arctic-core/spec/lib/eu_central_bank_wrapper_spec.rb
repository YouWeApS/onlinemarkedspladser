require "rails_helper"

RSpec.describe EuCentralBankWrapper do
  subject { described_class }

  its(:instance) { is_expected.to be_a EuCentralBank }

  describe '.update_rates' do
    it 'calls the instance' do
      expect(subject.instance).to receive(:update_rates)
      subject.update_rates
    end
  end
end
