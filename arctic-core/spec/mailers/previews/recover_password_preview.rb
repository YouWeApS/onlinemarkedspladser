# frozen_string_literal: true

class RecoverPasswordPreview < ActionMailer::Preview
  def start_flow
    user = FactoryBot.create(:user, :with_password_reset_token)
    RecoverPasswordMailer.start_flow user.email
  end
end
