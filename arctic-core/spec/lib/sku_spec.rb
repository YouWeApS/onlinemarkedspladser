require "rails_helper"

RSpec.describe Sku do
  skus = {
    'Order #1' => 'Order+1',
    'Prod.1' => 'Prod1',
    '18120Rø/HV' => '18120R+HV',
    '10080-10+stk-158+x+220+mm+A5' => '10080-10+stk-158+x+220+mm+A5',
    '10080-10+2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2Bstk-158+2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2Bx+2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B220+2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2Bmm+2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2BA5' => '10080-10+stk-158+x+220+mm+A5',
  }

  skus.each do |raw, parsed|
    it "parses #{raw} -> #{parsed}" do
      sku = Sku.new(raw)
      expect(sku.to_s).to eql parsed
    end
  end
end
