require "rails_helper"

RSpec.describe V1::Ui::ProductExportMailer, type: :mailer do
  it { is_expected.to be_a V1::ApplicationMailer }

  describe '#send_link' do
    let(:user) { create :user }
    let(:url) { 'https://somewhere.com?a=b&c=d' }
    subject { described_class.send_link user.id, url }

    its(:to) { is_expected.to match_array [user.email] }
    its(:from) { is_expected.to match_array ['no-reply@yourdomain.com'] }

    its(:subject) { is_expected.to eql 'Product data export ready' }
    it_behaves_like :translated_locale, 'v1.ui.product_export_mailer.send_link.subject'

    it { expect(subject.body.encoded).to include 'Here is the link to the product export you requested' }
    it_behaves_like :translated_locale, 'v1.ui.product_export_mailer.send_link.intro'

    it { expect(subject.body.encoded).to include 'https://somewhere.com?a=b&amp;c=d' }

    it { expect(subject.body.encoded).to include 'The link is only active for 48 hours. Please download the file before then.' }
    it_behaves_like :translated_locale, 'v1.ui.product_export_mailer.send_link.time_constraint'
  end
end
