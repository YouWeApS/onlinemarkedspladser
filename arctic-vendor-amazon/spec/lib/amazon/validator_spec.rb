require "spec_helper"

RSpec.describe Amazon::Validator do
  include_context :product

  let(:instance) { described_class.new product, **options }
  let(:options) { {} }

  subject { instance }

  its(:product) { is_expected.to eql product.as_json }
  its(:options) { is_expected.to eql options }
  its(:errors) { is_expected.to be_a Hash }

  describe '#valid?' do
    subject { instance.valid? }

    it { is_expected.to be_truthy }

    context 'missing categories' do
      before { product.delete :categories }
      it { is_expected.to be_falsey }
    end

    context 'missing images' do
      before { product.delete :images }
      it { is_expected.to be_falsey }
    end

    context 'invalid xml' do
      before do
        validator = double \
          errors: [
            "7:0: ERROR: Element 'ClothingType': [facet 'enumeration'] The value 'bbbb' is not an element of the set {'Shirt', 'Sweater', 'Pants', 'Shorts', 'Skirt', 'Dress', 'Suit', 'Blazer', 'Outerwear', 'SocksHosiery', 'Underwear', 'Bra', 'Shoes', 'Hat', 'Bag', 'Accessory', 'Jewelry', 'Sleepwear', 'Swimwear', 'PersonalBodyCare', 'HomeAccessory', 'NonApparelMisc', 'Kimono', 'Obi', 'Chanchanko', 'Jinbei', 'Yukata', 'EthnicWear', 'Costume', 'AdultCostume', 'BabyCostume', 'ChildrensCostume'}.",
            "7:0: ERROR: Element 'ClothingType': 'bbbb' is not a valid value of the local atomic type."
          ],
          validate: false
        expect(AmazonFeedValidator).to receive(:new).and_return validator
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#errors' do
    subject { instance.valid?; instance.errors }

    it { is_expected.to be_empty }

    context 'missing categories' do
      before { product.delete :categories }
      it { is_expected.to eql categories: ['is missing'] }
    end

    context 'missing images' do
      before { product.delete :images }
      it { is_expected.to eql images: ['is missing'] }
    end

    context 'invalid xml' do
      before do
        validator = double \
          errors: [
            "7:0: ERROR: Element 'ClothingType': [facet 'enumeration'] The value 'bbbb' is not an element of the set {'Shirt', 'Sweater', 'Pants', 'Shorts', 'Skirt', 'Dress', 'Suit', 'Blazer', 'Outerwear', 'SocksHosiery', 'Underwear', 'Bra', 'Shoes', 'Hat', 'Bag', 'Accessory', 'Jewelry', 'Sleepwear', 'Swimwear', 'PersonalBodyCare', 'HomeAccessory', 'NonApparelMisc', 'Kimono', 'Obi', 'Chanchanko', 'Jinbei', 'Yukata', 'EthnicWear', 'Costume', 'AdultCostume', 'BabyCostume', 'ChildrensCostume'}.",
            "7:0: ERROR: Element 'ClothingType': 'bbbb' is not a valid value of the local atomic type."
          ],
          validate: false
        expect(AmazonFeedValidator).to receive(:new).and_return validator
      end

      it 'returns the correctly formatted errors' do
        is_expected.to eql 'ClothingType' => [
          "[facet 'enumeration'] The value 'bbbb' is not an element of the set {'Shirt', 'Sweater', 'Pants', 'Shorts', 'Skirt', 'Dress', 'Suit', 'Blazer', 'Outerwear', 'SocksHosiery', 'Underwear', 'Bra', 'Shoes', 'Hat', 'Bag', 'Accessory', 'Jewelry', 'Sleepwear', 'Swimwear', 'PersonalBodyCare', 'HomeAccessory', 'NonApparelMisc', 'Kimono', 'Obi', 'Chanchanko', 'Jinbei', 'Yukata', 'EthnicWear', 'Costume', 'AdultCostume', 'BabyCostume', 'ChildrensCostume'}.",
          "'bbbb' is not a valid value of the local atomic type."
        ]
      end
    end
  end
end
