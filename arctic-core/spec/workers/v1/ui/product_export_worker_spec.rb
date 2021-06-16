require 'rails_helper'

RSpec.describe V1::Ui::ProductExportWorker, type: :worker do
  let(:instance) { described_class.new }

  it { is_expected.to be_processed_in :product_exports }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_retryable true }

  let(:perform) { instance.perform user.id, vendor.id, shop.id }

  let(:user) { create :user }
  let(:vendor) { create :vendor }
  let(:shop) { create :shop }

  it 'calls the ProductExport class and emails the link' do
    export = double
    expect(ProductExport).to receive(:new).with(vendor, shop).and_return export
    expect(export).to receive(:generate)

    url = 'https://somewhere.com'
    expect(export).to receive(:url).and_return url

    mailer = double
    expect(V1::Ui::ProductExportMailer).to receive(:send_link).with(user.id, url).and_return mailer
    expect(mailer).to receive(:deliver_later)

    perform
  end
end
