# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shop, type: :model do
  it { is_expected.to belong_to :account }

  it { is_expected.to have_many :dispersal_vendor_configurations }
  it { is_expected.to have_many :dispersal_vendors }
  it { is_expected.to have_many :collection_vendor_configurations }
  it { is_expected.to have_many :collection_vendors }
  it { is_expected.to have_many :products }
  it { is_expected.to have_many :currency_conversions }
  it { is_expected.to have_many :orders }
  it { is_expected.to have_many :vendor_shop_configurations }
  it { is_expected.to have_many :vendors }
end
