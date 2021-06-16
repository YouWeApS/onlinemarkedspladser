# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductPrice, type: :model do
  it { is_expected.to validate_presence_of :cents }
  it { is_expected.to validate_presence_of :currency }

  it { is_expected.to monetize(:cents).as(:price).with_currency(:dkk) }

  describe '.current' do
    subject { described_class.current }

    let!(:pp1) { create :product_price }
    let!(:pp2) { create :product_price, :expired }

    it { is_expected.to include pp1 }
    it { is_expected.not_to include pp2 }
  end

  describe 'default scope' do
    subject { described_class.all }

    let!(:pp1) { create :product_price }
    let!(:pp2) { create :product_price, :expired }

    it { is_expected.to include pp1 }
    it { is_expected.not_to include pp2 }
  end
end
