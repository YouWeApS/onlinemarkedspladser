# frozen_string_literal: true

class V1::Ui::DispersalBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  field :state

  field :channel do |dispersal|
    dispersal.vendor.name
  end

  field :updated_at, datetime_format: DATE_FORMAT
end
