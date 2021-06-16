# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecoverPasswordMailer, type: :mailer do
  describe '#start_flow' do
    let(:user) { create :user, :with_password_reset_token }
    let(:email) { user.email }
    let(:mail) { RecoverPasswordMailer.start_flow(email) }

    it 'has the correct headers' do
      expect(mail.subject).to eq('Recover your password')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['no-reply@yourdomain.com'])
    end

    it 'has the link to the reset flow UI' do
      url = "#{user.password_reset_redirect_to}?token=#{user.password_reset_token}"
      expect(mail.body.encoded).to include url
    end
  end
end
