# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dispersal, type: :model do
  let(:dispersal) { create :dispersal }

  it { is_expected.to belong_to :vendor_shop_configuration }
  it { is_expected.to belong_to :product }

  it { is_expected.to delegate_method(:vendor).to :vendor_shop_configuration }

  it { expect(described_class::STATES).to match_array %w[pending inprogress completed failed] }

  describe '.with_state' do
    subject { described_class.with_state *states }

    let!(:d1) { create :dispersal, state: :pending }
    let!(:d2) { create :dispersal, state: :inprogress }
    let!(:d3) { create :dispersal, state: :completed }
    let!(:d4) { create :dispersal, state: :failed }

    context 'single state' do
      let(:states) { %i[pending] }
      it { is_expected.to match_array [d1] }
    end

    context 'multiple states state' do
      let(:states) { %i[pending inprogress] }
      it { is_expected.to match_array [d1, d2] }
    end
  end

  describe '.incomplete' do
    subject { described_class.incomplete }

    let!(:d1) { create :dispersal, state: :pending }
    let!(:d2) { create :dispersal, state: :inprogress }
    let!(:d3) { create :dispersal, state: :completed }
    let!(:d4) { create :dispersal, state: :failed }

    context 'returns incomplete dispersals' do
      it { is_expected.to match_array [d1, d2, d4] }
    end
  end
end
