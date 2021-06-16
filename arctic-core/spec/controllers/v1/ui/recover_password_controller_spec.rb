# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::RecoverPasswordController, type: :controller do

  describe '#reset' do
    let!(:user) { create :user, :with_password_reset_token }

    let(:action) { post :reset, params: params }

    let(:params) do
      {
        password: 'new-password',
        password_confirmation: 'new-password',
        token: user.password_reset_token,
      }
    end

    it_behaves_like :http_status, 205

    it 'updates the password' do
      action
      expect(user.reload.authenticate('new-password')).to eql user
    end

    it 'clears the password_reset_token' do
      expect { action }.to change { user.reload.password_reset_token }.to(nil)
    end

    it 'clears the password_reset_token_expires_at' do
      expect { action }.to change { user.reload.password_reset_token_expires_at }.to(nil)
    end

    it 'clears the password_reset_redirect_to' do
      expect { action }.to change { user.reload.password_reset_redirect_to }.to(nil)
    end
  end

  describe '#start_flow' do
    let!(:user) { create :user }

    let(:action) { post :start_flow, params: params }

    let(:params) do
      {
        email: user.email,
        redirect_to: 'https://somewhere.com/set_new_password',
      }
    end

    it_behaves_like :http_status, 202

    it 'attempts to send the email to the user' do
      mailer = double
      expect(RecoverPasswordMailer).to receive(:start_flow)
        .with(params[:email])
        .and_return(mailer)
      expect(mailer).to receive(:deliver_now)
      action
    end

    it 'generates a password reset token for the user' do
      expect { action }.to change { user.reload.password_reset_token }.from(nil)
    end

    it 'sets the password reset token expiration date' do
      Timecop.freeze do
        expect { action }.to change {
          user.reload.password_reset_token_expires_at
        }.from(nil).to be_within(1.second).of(30.minutes.from_now)
      end
    end

    it 'updates the password_reset_redirect_to' do
      expect { action }.to change {
        user.reload.password_reset_redirect_to
      }.from(nil).to params[:redirect_to]
    end

    describe 'missing email' do
      before { params.delete :email }
      it_behaves_like :http_status, 400
    end

    describe 'invalid email' do
      before { params[:email] = 'hello' }
      it_behaves_like :http_status, 202
    end

    describe 'missing redirect_to' do
      before { params.delete :redirect_to }
      it_behaves_like :http_status, 400
    end
  end
end
