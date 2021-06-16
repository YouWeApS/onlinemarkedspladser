# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  let(:instance) { build :product_image }
  subject { instance }

  it { is_expected.to belong_to :product }
  it { is_expected.to validate_presence_of :position }
  it { is_expected.to validate_presence_of :url }

  describe 'acts_as_list' do
    let(:product) { create :product }
    let!(:product_image1) { create :product_image, product: product, position: 0 }
    let!(:product_image2) { create :product_image, product: product, position: 1 }

    it 'sorts product images by position' do
      expect(product.images).to match_array [product_image1, product_image2]
    end

    it 'is possible to change positions' do
      product_image1.move_to_bottom
      expect(product.images).to match_array [product_image2, product_image1]
    end
  end
end
