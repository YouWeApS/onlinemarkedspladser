# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShadowProduct, type: :model do
  let(:shop) { create :shop }
  let(:product) { create :product, :with_prices, shop: shop }
  let(:shadow_product) { create :shadow_product, product: product }
  let(:merged_product) { ProductMerger.new(product, vendor: shadow_product.vendor).result }

  it { is_expected.to belong_to :product }
  it { is_expected.to belong_to :vendor_shop_configuration }
  it { is_expected.to belong_to :offer_price }
  it { is_expected.to belong_to :original_price }

  it { is_expected.to have_many :dispersals }
  it { is_expected.to have_many :product_errors }

  it { is_expected.to have_one :master }

  it_behaves_like :having_product_attributes

  it 'validates description length' do
    shadow_product.description = '1' * 2000
    expect(shadow_product).to be_valid
    shadow_product.description = '1' * 2001
    expect(shadow_product).not_to be_valid
    expect { shadow_product.save(validate: false) }.to raise_error ActiveRecord::ValueTooLong
  end

  Product::CHARACTERISTICS.except('description').each do |field|
    it "#{field} is limited to 256 characters" do
      shadow_product.public_send "#{field}=", ('1' * 256)
      expect(shadow_product).to be_valid
      shadow_product.public_send "#{field}=", ('1' * 257)
      expect(shadow_product).not_to be_valid
      expect { shadow_product.save(validate: false) }.to raise_error ActiveRecord::ValueTooLong
    end
  end

  describe '#offer_price' do
    subject { shadow_product.offer_price }
    it { is_expected.to be_nil }

    context 'on shadow product' do
      before { shadow_product.offer_price = create :product_price }
      it { is_expected.not_to eql product.offer_price }
      it { is_expected.to be_a ProductPrice }
    end
  end

  describe '#original_price' do
    subject { shadow_product.original_price }
    it { is_expected.to be_nil }

    context 'on shadow product' do
      before { shadow_product.original_price = create :product_price }
      it { is_expected.not_to eql product.original_price }
      it { is_expected.to be_a ProductPrice }
    end
  end

  describe 'assigning EAN' do
    it 'nulls if ean is blank' do
      shadow_product.update ean: ''
      expect(shadow_product.reload.ean).to be_nil
    end
  end

  it 'is possible to restore a shadow product' do
    shadow_product.destroy
    expect { shadow_product.reload.restore }.not_to raise_error
  end

  it "can still access it's destroyed product" do
    shadow = create :shadow_product
    shadow.product.destroy
    expect(shadow.reload.product).to be_present
  end
end
