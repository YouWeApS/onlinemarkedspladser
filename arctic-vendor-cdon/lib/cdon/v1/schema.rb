# frozen_string_literal: true

require_relative '../v1'

# Documentation: http://bit.ly/2qpMV6S

class CDON::V1::Schema
  attr_reader :xml, :errors

  def initialize(xml)
    @xml = Nokogiri::XML xml
  end

  def valid?
    @errors = validator.validate(xml).collect(&:message)
    errors.empty?
  end

  private

    def validator
      @validator = begin
        xsd_path = File.expand_path './schema.xsd', __dir__
        Nokogiri::XML::Schema File.read(xsd_path)
      end
    end
end
