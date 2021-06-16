# frozen_string_literal: true

class V1::Vendors::LastSyncedAtBlueprint < Blueprinter::Base #:nodoc:
  view :orders do
    field :last_synced_at do |object|
      object.orders_last_synced_at.try(:httpdate)
    end
  end

  view :products do
    field :last_synced_at do |object|
      object.last_synced_at.try(:httpdate)
    end
  end
end
