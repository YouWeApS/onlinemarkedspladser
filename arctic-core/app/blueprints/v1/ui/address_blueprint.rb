# frozen_string_literal: true

class V1::Ui::AddressBlueprint < Blueprinter::Base #:nodoc:
  fields :name, :address1, :city, :zip, :email, :phone

  field :country do |address|
    address.country.to_s
  end
end
