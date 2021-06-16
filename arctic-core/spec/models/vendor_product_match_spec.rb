# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VendorProductMatch, type: :model do
  it { is_expected.to belong_to :vendor_shop_configuration }
  it { is_expected.to belong_to :product }

  it { is_expected.to delegate_method(:vendor).to :vendor_shop_configuration }

  describe '.matched' do
    subject { described_class.matched }
    let!(:match1) { create :vendor_product_match, matched: true }
    let!(:match2) { create :vendor_product_match, matched: false }
    it { is_expected.to match_array match1 }
  end

  describe '.unmatched' do
    subject { described_class.unmatched }
    let!(:match1) { create :vendor_product_match, matched: true }
    let!(:match2) { create :vendor_product_match, matched: false }
    it { is_expected.to match_array match2 }
  end
end
