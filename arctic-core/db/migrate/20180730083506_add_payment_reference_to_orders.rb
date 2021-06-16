# frozen_string_literal: true

class AddPaymentReferenceToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :payment_reference, :string
  end
end
