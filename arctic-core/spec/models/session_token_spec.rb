# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionToken, type: :model do
  it { is_expected.to belong_to :user }
end
