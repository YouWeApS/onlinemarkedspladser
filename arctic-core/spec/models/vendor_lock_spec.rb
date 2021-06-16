require 'rails_helper'

RSpec.describe VendorLock, type: :model do
  let(:instance) { build :vendor_lock }
  subject { instance }

  it { is_expected.to belong_to :target }
  it { is_expected.to belong_to :vendor }

  describe '.stale' do
    subject { described_class.stale }

    let!(:lock1) { create :vendor_lock, created_at: 59.minutes.ago }
    let!(:lock2) { create :vendor_lock, created_at: 61.minutes.ago }

    it { is_expected.to match_array [lock2] }
  end
end
