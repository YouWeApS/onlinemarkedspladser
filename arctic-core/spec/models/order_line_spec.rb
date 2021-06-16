require 'rails_helper'

RSpec.describe OrderLine, type: :model do
  let(:instance) { build :order_line }
  subject { instance }

  it { is_expected.to belong_to :order }
  it { is_expected.to belong_to :product }

  it { is_expected.to validate_presence_of :status }
  # it { is_expected.to validate_inclusion_of(:status).in_array OrderLine::STATUSES.keys }

  it 'is possible to create with none-existing-product' do
    expect { create :order_line, product: nil }.not_to raise_error
  end

  describe '#invoices' do
    let!(:order) { create :order }
    let!(:invoice) { create :order_invoice, order: order, order_lines: [order_line.line_id] }
    let!(:order_line) { create(:order_line, order: order) }
    subject { order_line.invoices }
    it { is_expected.to match_array [invoice] }
  end

  context 'the same products in different order lines' do
    let!(:product){ create :product }
    let!(:order) { create :order }
    let!(:order_line) { create(:order_line, order: order, product: product) }
    it 'raise error for duplicated products and orders' do
      expect { create :order_line, order: order, product: product }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  context 'missing both cents_without_vat and cents_with_vat' do
    before do
      instance.cents_with_vat = instance.cents_without_vat = nil
    end

    it { is_expected.not_to be_valid }

    it 'adds an error to the price field' do
      instance.valid?
      expect(instance.errors[:price]).to match_array ['one of cents_without_vat or cents_with_vat must be present']
    end
  end

  context 'Change status if was track changed' do
    describe '#change_status_with_track_and_trace' do
      let!(:order) { create :order }
      let!(:test_line) { create(:order_line, order: order, track_and_trace_reference: nil) }
      it { expect(test_line).to have_attributes(:status => "created") }

      it 'update track_and_trace_reference' do
        expect { test_line.update(track_and_trace_reference: '66cef42e0451eac16a1577b075445a8e') }
          .to change { test_line.status }.from("created").to("shipped")
      end
    end
  end
end
