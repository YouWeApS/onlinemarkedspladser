# frozen_string_literal: true

class V1::Vendors::ImportMapBlueprint < Blueprinter::Base
  identifier :id

  fields :from, :to, :regex, :default, :position
end
