# frozen_string_literal: true

class OrderLine < ApplicationRecord
  STATUSES = {
    'created'   => 0,
    'shipped'   => 1,
    'invoiced'  => 2,
    'completed' => 3,
  }.freeze

  enum status: STATUSES

  belongs_to :order
  belongs_to :product, optional: true

  validates :product, presence: true, on: :update
  validates :status, presence: true, inclusion: { in: STATUSES.keys }
  validate :price_present

  before_validation :create_mock_product
  before_update :change_status_with_track_and_trace

  def invoices
    OrderInvoice
      .where(order: order)
      .where('order_lines::jsonb ? :line_id', line_id: line_id)
  end

  private

    def price_present
      return if cents_without_vat.present? || cents_with_vat.present?

      errors.add :price, 'one of cents_without_vat or cents_with_vat must be present'
    end

    def create_mock_product
      prod = Product.unscoped.where(id: product_id).take
      prod ||= Product.create! \
        sku: product_id,
        name: "Mock product for #{product_id}",
        shop: order.shop,
        deleted_at: 1.second.ago
      self.product = prod
    end

    def change_status_with_track_and_trace
      self.status = :shipped if track_and_trace_reference_changed?
    end
end
