# frozen_string_literal: true

class V1::Ui::ProductErrorBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :message, :details, :severity
end
