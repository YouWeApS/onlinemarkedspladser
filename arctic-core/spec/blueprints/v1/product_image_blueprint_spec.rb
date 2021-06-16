# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::ProductImageBlueprint do
  subject { Hashie::Mash.new described_class.render_as_hash(product_image) }
  let(:product_image) { create :product_image }

  its(:id) { is_expected.to eql(product_image.id) }
  its(:url) { is_expected.to eql(product_image.url) }
  its(:position) { is_expected.to eql(product_image.position) }
end
