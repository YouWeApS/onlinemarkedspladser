# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductError, type: :model do
  it { is_expected.to belong_to :shadow_product }

  it { is_expected.to validate_presence_of :message }
  it { is_expected.to validate_presence_of :severity }

  it { is_expected.to validate_inclusion_of(:severity).in_array %w[error warning] }
end
