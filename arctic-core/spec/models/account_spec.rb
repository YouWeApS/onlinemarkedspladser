# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  it { is_expected.to have_many :user_accounts }
  it { is_expected.to have_many :users }
  it { is_expected.to have_many :shops }
end
