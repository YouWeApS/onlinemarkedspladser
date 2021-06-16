# frozen_string_literal: true

class V1::Vendors::UpdateScheduledBlueprint < Blueprinter::Base #:nodoc:
  field :original_sku do |object|
    object.original_sku.to_s
  end
end
