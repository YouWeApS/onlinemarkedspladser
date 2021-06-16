require "rails_helper"

RSpec.describe AlphaNumSku do
  skus = {
    'Order #1' => 'Order1',
    'Prod.1' => 'Prod1',
    '18120Rø/HV' => '18120RHV',
  }

  skus.each do |raw, parsed|
    it "parses #{raw} -> #{parsed}" do
      sku = AlphaNumSku.new(raw)
      expect(sku.to_s).to eql parsed
    end
  end
end
