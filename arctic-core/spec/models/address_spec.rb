# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:instance) { build :address }
  subject { instance }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :address1 }
  it { is_expected.to validate_presence_of :city }
  it { is_expected.to validate_presence_of :zip }
  it { is_expected.to validate_presence_of :email }

  it 'validates country abbreviation with ISO 3166' do
    expect { instance.country = 'dk' }.to change { instance.country }.to eql ISO3166::Country.new('DK')
  end

  it 'validates country full name' do
    expect { instance.country = 'Sweden' }.to change { instance.country }.to eql ISO3166::Country.find_country_by_name('Sweden')
  end
end
