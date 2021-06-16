# Preview all emails at http://localhost:3000/rails/mailers/v1/ui/product_import
class V1::Ui::ProductImportMailerPreview < ActionMailer::Preview
  def failed
    user = User.first || create(:user)
    filename = "#{SecureRandom.hex(6)}.csv"
    V1::Ui::ProductImportMailer.failed user.id, filename
  end

  def completed
    user = User.first || create(:user)
    filename = "#{SecureRandom.hex(6)}.csv"
    V1::Ui::ProductImportMailer.completed user.id, filename
  end
end
