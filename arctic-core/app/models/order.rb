# frozen_string_literal: true

require 'sku'

class Order < ApplicationRecord #:nodoc:
  belongs_to :shipping_address, class_name: 'Address', foreign_key: :delivery_address_id
  belongs_to :billing_address, class_name: 'Address'
  belongs_to :shop
  belongs_to :vendor
  belongs_to :shipping_method, optional: true
  belongs_to :shipping_carrier, optional: true

  has_many :raw_data, class_name: 'OrderRawData'
  has_many :invoices, class_name: 'OrderInvoice'
  has_many :order_lines
  has_many :vendor_locks, as: :target

  alias_attribute :receipt_id, :order_receipt_id

  accepts_nested_attributes_for :order_lines

  def total_with_vat
    @total_with_vat ||= begin
      cents = order_lines.pluck(:cents_with_vat).compact.sum
      cents += shipping_fee + payment_fee
      Money.new cents, currency
    end
  end

  def total_without_vat
    @total_without_vat ||= begin
      cents = order_lines.pluck(:cents_without_vat).compact.sum
      cents += shipping_fee + payment_fee
      Money.new cents, currency
    end
  end

  def self.unlocked(vendor)
    where.not(id: locked_order_ids(vendor))
  end

  def self.locked_order_ids(vendor)
    Order
      .left_outer_joins(:vendor_locks)
      .where(vendor_locks: { vendor: vendor })
      .where('vendor_locks.created_at > ?', 1.hour.ago)
      .pluck(:id)
  end

  def order_id=(new_id)
    super Sku.new(new_id).to_s
  end

  def all_track_and_trace_references
    @all_track_and_trace_references ||= order_lines.pluck :track_and_trace_reference
  end

  def status
    order_lines.pluck(:status).compact.uniq
  end

  def purchased_at
    super || created_at
  end

  def self.search(string)
    return where(nil) if string.to_s.blank?

    orders1 = where('payment_reference ~ ?', string.to_s)

    order_ids = OrderLine.where('track_and_trace_reference ~ ?', string.to_s).pluck(:order_id)
    orders2 = Order.where id: order_ids

    orders1.union orders2
  end

  def self.before(date)
    date = Chronic.parse(date.to_s)
    return where(nil) unless date

    sql = <<-SQL
      orders.created_at <= :date or
      orders.purchased_at <= :date
    SQL

    where sql, date: date.end_of_day
  end

  def self.after(date)
    date = Chronic.parse(date.to_s)
    return where(nil) unless date

    sql = <<-SQL
      orders.created_at >= :date or
      orders.purchased_at >= :date
    SQL

    where sql, date: date.beginning_of_day
  end
end
