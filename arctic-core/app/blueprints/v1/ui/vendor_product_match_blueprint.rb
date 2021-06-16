# frozen_string_literal: true

class V1::Ui::VendorProductMatchBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  field :matched
  field :error, name: :errors
end
