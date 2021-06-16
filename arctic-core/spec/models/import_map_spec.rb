# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportMap, type: :model do
  it { is_expected.to belong_to :vendor_shop_configuration }
  it { is_expected.to validate_presence_of :from }
  it { is_expected.to validate_presence_of :to }
end
