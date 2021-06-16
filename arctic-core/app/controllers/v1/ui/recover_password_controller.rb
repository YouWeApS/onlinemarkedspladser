# frozen_string_literal: true

class V1::Ui::RecoverPasswordController < V1::ApplicationController #:nodoc:
  def reset
    user = User.where(password_reset_token: params[:token]).take!

    user.attributes = reset_params

    user.password_reset_token = nil
    user.password_reset_token_expires_at = nil
    user.password_reset_redirect_to = nil

    user.save!

    head :reset_content
  end

  def start_flow
    if params[:email].blank? || params[:redirect_to].blank?
      raise HttpError::BadRequest, 'Missing parameters email or redirect_to'
    end

    user = User.where(email: params[:email]).take

    email_reset_token user if user

    # Always return 202 Accepted as a security meassure not to notify the client
    # if the email exists or not
    head :accepted
  end

  private

    def reset_params
      params.permit :password, :password_confirmation
    end

    def email_reset_token(user)
      user.update \
        password_reset_token: SecureRandom.uuid,
        password_reset_token_expires_at: 30.minutes.from_now,
        password_reset_redirect_to: params[:redirect_to]

      RecoverPasswordMailer
        .start_flow(user.email)
        .deliver_now
    end
end
