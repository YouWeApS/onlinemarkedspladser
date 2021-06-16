# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:instance) { build :user }

  it { is_expected.to have_secure_password }

  it { is_expected.to have_many :access_grants }
  it { is_expected.to have_many :access_tokens }
  it { is_expected.to have_many :access_tokens }
  it { is_expected.to have_many :session_tokens }
  it { is_expected.to have_many :user_accounts }
  it { is_expected.to have_many :accounts }
  it { is_expected.to have_many :shops }
  it { is_expected.to have_many :vendors }

  it { is_expected.to validate_confirmation_of :password }

  describe '#avatar' do
    it 'can be attached' do
      io = File.open Rails.root.join('spec', 'fixtures', 'images', 'mathilde.jpg')
      instance.avatar.attach \
        io: io,
        filename: 'mathilde.jpg',
        content_type: 'image/jpg'
      expect(instance.avatar).to be_attached
    end
  end

  describe '.find_and_authenticate' do
    subject { described_class.find_and_authenticate email, password }

    let!(:user) { create :user }
    let(:email) { user.email }
    let(:password) { 'password' }

    it { is_expected.to eql user }

    context 'invalid password' do
      let(:password) { 'hello' }
      it { expect { subject }.to raise_error HttpError::Unauthorized }
    end

    context 'invalid email' do
      let(:email) { 'bob' }
      it { expect { subject }.to raise_error HttpError::Unauthorized }
    end
  end
end
