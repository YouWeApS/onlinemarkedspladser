# frozen_string_literal: true

class OrderInvoice < ApplicationRecord
  STATUSES = %w[
    awaiting_payment
    payment_completed
  ].freeze

  belongs_to :order

  validates :cents, presence: true
  validates :currency, presence: true
  validates :invoice_id, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  monetize :cents, as: :total

  def amount=(not_cents)
    self.cents = Float(not_cents) * 100.0
  end
end
