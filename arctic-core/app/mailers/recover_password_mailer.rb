# frozen_string_literal: true

class RecoverPasswordMailer < V1::ApplicationMailer #:nodoc:
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.recover_password_mailer.start_flow.subject
  #
  def start_flow(email)
    find_user email

    # In case the password_reset_redirect_to url has query parameters, we add
    # the password reset token qithout removing any of the existing parameters.
    uri = URI.parse @user.password_reset_redirect_to
    new_query_ar = URI.decode_www_form String(uri.query)
    new_query_ar << ['token', @user.password_reset_token]
    uri.query = URI.encode_www_form new_query_ar
    @reset_url = uri.to_s

    mail to: email
  end
end
