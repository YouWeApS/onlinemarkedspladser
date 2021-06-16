# frozen_string_literal: true

class V1::Vendors::AddressBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields \
    :name,
    :address1,
    :address2,
    :zip,
    :city,
    :region,
    :email,
    :phone

  field :country do |address|
    address.country.alpha2
  end
end
