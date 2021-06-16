# frozen_string_literal: true

class V1::Ui::CategoryMapBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :value, :source, :name, :position
end
