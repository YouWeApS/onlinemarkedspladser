require "rails_helper"

RSpec.describe V1::Ui::ProductImportMailer, type: :mailer do
  it { is_expected.to be_a V1::ApplicationMailer }

  describe '#failed' do
    let(:user) { create :user }
    subject { described_class.failed user.id, 'file.csv' }

    its(:to) { is_expected.to match_array [user.email] }
    its(:from) { is_expected.to match_array ['no-reply@yourdomain.com'] }

    its(:subject) { is_expected.to eql 'Product data import failed' }
    it_behaves_like :translated_locale, 'v1.ui.product_import_mailer.failed.subject'

    it { expect(subject.body.encoded).to include 'Product data import of file.csv failed' }
    it_behaves_like :translated_locale, 'v1.ui.product_import_mailer.failed.intro'

    it { expect(subject.body.encoded).to include 'Please correct the errors in the file and try again' }
    it_behaves_like :translated_locale, 'v1.ui.product_import_mailer.failed.retry'
  end

  describe '#completed' do
    let(:user) { create :user }
    subject { described_class.completed user.id, 'file.csv' }

    its(:to) { is_expected.to match_array [user.email] }
    its(:from) { is_expected.to match_array ['no-reply@yourdomain.com'] }

    its(:subject) { is_expected.to eql 'Product data import has completed' }
    it_behaves_like :translated_locale, 'v1.ui.product_import_mailer.completed.subject'

    it { expect(subject.body.encoded).to include 'Product data import of file.csv has completed' }
    it_behaves_like :translated_locale, 'v1.ui.product_import_mailer.completed.intro'
  end
end
