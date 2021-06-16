require 'rails_helper'

RSpec.describe OrderInvoice, type: :model do
  let(:instance) { build :order_invoice }
  subject { instance }

  it { is_expected.to belong_to :order }

  it { is_expected.to validate_presence_of :cents }
  it { is_expected.to validate_presence_of :currency }
  it { is_expected.to validate_presence_of :invoice_id }
  it { is_expected.to validate_presence_of :status }

  it { is_expected.to validate_inclusion_of(:status).in_array(OrderInvoice::STATUSES) }

  describe '#amount=' do
    subject { instance.amount = 12.34 }
    it { expect { subject }.to change { instance.cents }.from(1000).to 1234 }
  end
end
