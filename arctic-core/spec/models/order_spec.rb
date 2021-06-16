# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  it { is_expected.to belong_to :billing_address }
  it { is_expected.to belong_to :shipping_address }
  it { is_expected.to belong_to :shop }
  it { is_expected.to belong_to :vendor }

  it { is_expected.to have_many :raw_data }
  it { is_expected.to have_many :invoices }
  it { is_expected.to have_many :order_lines }
  it { is_expected.to have_many :vendor_locks }

  it 'encodes the order ID' do
    instance = described_class.new
    instance.order_id = 'Order #1'
    expect(instance.order_id).to eql 'Order+1'
  end

  describe '#total_with_vat' do
    let(:order) { create :order, shipping_fee: 111, payment_fee: 222 }
    let!(:ol1) { create :order_line, order: order, cents_with_vat: 1234 }
    let!(:ol2) { create :order_line, order: order, cents_with_vat: 5678 }

    subject { order.total_with_vat }

    it { is_expected.to eql Money.new (1234 + 5678 + 111 + 222), 'DKK' }

    context 'no order lines' do
      before do
        ol1.really_destroy!
        ol2.really_destroy!
      end

      it { is_expected.to eql Money.new 111 + 222, 'DKK' }
    end

    context 'orderline missing cents_with_vat' do
      before { ol1.update cents_with_vat: nil }
      it { is_expected.to eql Money.new 5678 + 111 + 222, 'DKK' }
    end
  end

  describe '#total_without_vat' do
    let(:order) { create :order, payment_fee: 111, shipping_fee: 222 }
    let!(:ol1) { create :order_line, order: order, cents_without_vat: 1234 }
    let!(:ol2) { create :order_line, order: order, cents_without_vat: 5678 }

    subject { order.total_without_vat }

    it { is_expected.to eql Money.new (1234 + 5678 + 111 + 222), 'DKK' }
  end

  describe '.unlocked' do
    subject { described_class.unlocked(vendor) }

    let!(:order1) { create :order }
    let!(:order2) { create :order }
    let(:vendor) { create :vendor }

    context 'locked by the vendor' do
      let!(:lock) { create :vendor_lock, target: order1, vendor: vendor }

      it { is_expected.to match_array [order2] }

      context 'expired lock' do
        before { lock.update created_at: 61.minutes.ago }

        it { is_expected.to match_array [order1, order2] }
      end
    end

    context 'locked by another vendor' do
      before { create :vendor_lock, target: order1 }
      it { is_expected.to match_array [order1, order2] }
    end
  end

  describe '#status' do
    subject { order.status }
    let(:order) { create :order }
    let!(:line1) { create :order_line, order: order, status: :created }
    let!(:line2) { create :order_line, order: order, status: :shipped }
    let!(:line3) { create :order_line, order: order, status: :shipped }
    it { is_expected.to match_array %w[created shipped] }
  end

  describe '#all_track_and_trace_references' do
    let(:order) { create :order }
    let!(:line1) { create :order_line, order: order, track_and_trace_reference: 'abcdef123' }

    it 'returns order line track ^ trace numbers' do
      expect(order.all_track_and_trace_references).to match_array %w[abcdef123]
    end
  end

  describe '.search' do
    subject { described_class.search(string) }

    let!(:order1) { create :order, payment_reference: 'c' }
    let!(:order1_line1) { create :order_line, order: order1, track_and_trace_reference: 'a' }
    let!(:order2) { create :order, payment_reference: 'd' }
    let!(:order2_line1) { create :order_line, order: order2, track_and_trace_reference: 'b' }

    let(:string) { nil }

    it { is_expected.to match_array [order1, order2] }

    context 'searching track_and_trace_reference' do
      let(:string) { 'a' }
      it { is_expected.to match_array [order1] }
    end

    context 'searching payment_reference' do
      let(:string) { 'd' }
      it { is_expected.to match_array [order2] }
    end
  end

  describe '.before' do
    subject { described_class.before(date) }

    let!(:order1) { create :order, created_at: 25.hours.ago.end_of_day }
    let!(:order2) { create :order, purchased_at: Time.now }

    let(:date) { nil }

    it { is_expected.to match_array [order1, order2] }

    describe 'with a specific date' do
      let(:date) { 25.hours.ago }
      it { is_expected.to match_array [order1] }
    end
  end

  describe '.after' do
    subject { described_class.after(date) }

    let!(:order1) { create :order, created_at: 25.hours.from_now.beginning_of_day }
    let!(:order2) { create :order, purchased_at: Time.now }

    let(:date) { nil }

    it { is_expected.to match_array [order1, order2] }

    describe 'with a specific date' do
      let(:date) { 25.hours.from_now }
      it { is_expected.to match_array [order1] }
    end
  end
end
