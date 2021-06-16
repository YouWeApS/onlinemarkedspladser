# frozen_string_literal: true

class V1::Ui::ProductImportMailer < V1::ApplicationMailer
  def failed(user_id, filename)
    @user = User.find user_id
    @filename = filename
    mail \
      subject: I18n.t('v1.ui.product_import_mailer.failed.subject'),
      to: @user.email
  end

  def completed(user_id, filename)
    @user = User.find user_id
    @filename = filename
    mail \
      subject: I18n.t('v1.ui.product_import_mailer.completed.subject'),
      to: @user.email
  end
end
