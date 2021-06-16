# frozen_string_literal: true

class V1::ApplicationMailer < ApplicationMailer #:nodoc:
  layout 'v1/mailer'

  private

    def find_user(email)
      @user = User.where(email: email).take!
    end
end
