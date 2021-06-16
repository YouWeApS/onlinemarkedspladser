# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyConversion, type: :model do
  it { is_expected.to belong_to :shop }

  it { is_expected.to validate_presence_of :from_currency }
  it { is_expected.to validate_presence_of :to_currency }
  it { is_expected.to validate_presence_of :rate }
  it { is_expected.to validate_numericality_of :rate }
end
