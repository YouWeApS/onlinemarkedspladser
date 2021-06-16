# Preview all emails at http://localhost:3000/rails/mailers/product_export
class V1::Ui::ProductExportMailerPreview < ActionMailer::Preview
  def send_link
    user ||= User.last || create(:user)
    url = 'http://google.com?q=product+data+download'
    V1::Ui::ProductExportMailer.send_link user.id, url
  end
end
