# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::UserBlueprint do
  subject { Hashie::Mash.new described_class.render_as_hash(user) }

  let(:user) { create :user }

  its(:id) { is_expected.to eql(user.id) }
  its(:email) { is_expected.to eql(user.email) }

  context 'with avatar' do
    before { allow(user).to receive(:avatar).and_return avatar }

    let(:avatar) do
      double \
        attached?: true,
        signed_id: 1,
        filename: 'avatar.jpg'
    end

    let(:host) do
      url = ENV.fetch 'HOST', 'localhost'
      url += ":#{ENV.fetch('WEB_PORT')}" if ENV.fetch('WEB_PORT', false)
      url
    end

    let(:expected_url) do
      "http://#{host}/rails/active_storage/blobs/1/avatar.jpg"
    end

    its(:avatar_url) { is_expected.to eql expected_url }

    context 'production env' do
      before do
        allow(Rails).to receive(:env).and_return double(production?: true)
      end

      let(:expected_url) do
        "https://#{host}/rails/active_storage/blobs/1/avatar.jpg"
      end

      its(:avatar_url) { is_expected.to eql expected_url }
    end
  end
end
