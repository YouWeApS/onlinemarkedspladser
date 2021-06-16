# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VendorShopCollectionConfiguration, type: :model do
  let(:instance) { build :vendor_shop_collection_configuration }
  subject { instance }

  it { is_expected.to be_a VendorShopConfiguration }
end
