FactoryBot.define do
  factory :vendor_lock do
    target { create(:order) }
    vendor { create :vendor }
  end
end
