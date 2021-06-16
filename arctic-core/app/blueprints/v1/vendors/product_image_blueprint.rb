# frozen_string_literal: true

class V1::Vendors::ProductImageBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :url, :position
end
