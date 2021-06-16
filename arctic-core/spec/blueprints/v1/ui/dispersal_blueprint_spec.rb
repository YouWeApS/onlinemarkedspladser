# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::DispersalBlueprint do
  subject { instance }

  let(:instance) { Hashie::Mash.new described_class.render_as_hash(dispersal) }

  let(:dispersal) { create :dispersal }

  its(:id) { is_expected.to eql(dispersal.id) }
  its(:state) { is_expected.to eql(dispersal.state) }
  its(:channel) { is_expected.to eql(dispersal.vendor.name) }

  # TODO: This could have simply been: `is_expected.to eql Time.now.httpdate`,
  #       but for some reason that returns the date in GTM, not UTC.
  describe 'updated_at', freeze: '2018-01-01 10:11:12' do
    subject { instance.updated_at.to_s }
    it { is_expected.to eql 'Mon, 01 Jan 2018 10:11:12 UTC' }
  end
end
