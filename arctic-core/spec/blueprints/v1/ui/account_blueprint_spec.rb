# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::AccountBlueprint do
  subject { Hashie::Mash.new described_class.render_as_hash(account) }

  let(:account) { create :account }

  its(:id) { is_expected.to eql(account.id) }
  its(:name) { is_expected.to eql(account.name) }
end
