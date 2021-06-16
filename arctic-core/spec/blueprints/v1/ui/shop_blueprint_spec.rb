# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::ShopBlueprint do
  subject { Hashie::Mash.new described_class.render_as_hash(shop) }

  let(:shop) { create :shop }

  its(:id) { is_expected.to eql(shop.id) }
  its(:name) { is_expected.to eql(shop.name) }
end
