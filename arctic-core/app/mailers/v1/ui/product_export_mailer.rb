# frozen_string_literal: true

class V1::Ui::ProductExportMailer < V1::ApplicationMailer
  def send_link(user_id, url)
    @user = User.find user_id
    @url = url

    mail \
      to: @user.email,
      subject: I18n.t('v1.ui.product_export_mailer.send_link.subject')
  end
end
