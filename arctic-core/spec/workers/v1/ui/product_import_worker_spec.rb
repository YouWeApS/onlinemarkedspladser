require 'rails_helper'

RSpec.describe V1::Ui::ProductImportWorker, type: :worker do
  let(:instance) { described_class.new }

  it { is_expected.to be_processed_in :product_imports }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_retryable true }

  let(:perform) { instance.perform user.id, vendor.id, shop.id, path }

  let(:account) { create :account }
  let(:user) { create :user, accounts: [account] }
  let(:vendor) { create :vendor }
  let(:shop) { create :shop, account: account }
  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }
  let(:path) { Rails.root.join('tmp', 'file.csv') }

  before do
    File.open(path, 'w') { |f| f.write 'Hello' }

    allow(S3Uploader).to receive(:new).and_return \
      double(upload: double(url_for: true))
  end

  describe '#perform' do
    it 'calls the ProductImport class with the right arguments' do
      import = double
      expect(ProductImport).to receive(:new).with(vendor, shop, path).and_return import
      expect(import).to receive(:save)
      perform
    end

    it 'removes the file after processing' do
      expect(FileUtils).to receive(:rm).with path
      perform
    end

    it 'sends a completed email to the user' do
      expect(V1::Ui::ProductImportMailer).not_to receive(:failed)
      mailer = double deliver_later: true
      expect(V1::Ui::ProductImportMailer).to receive(:completed).and_return mailer
      perform
    end

    it 'stores the imported file on s3' do
      uploader = double
      expect(S3Uploader).to receive(:new).and_return uploader
      expect(uploader).to receive(:upload).with(path).and_return uploader
      expect(uploader).to receive(:url_for).with(path).and_return 'https://somewhere.com'
      filename = File.basename path
      allow(Rails.logger).to receive(:info).with(nil).at_least(:once)
      expect(Rails.logger).to receive(:info).with("Stored import file #{filename} in https://somewhere.com")
      perform
    end

    context 'product import fails' do
      before { expect_any_instance_of(ProductImport).to receive(:save).and_return false }

      it 'emails the failure to the user' do
        mailer = double
        expect(V1::Ui::ProductImportMailer).to receive(:failed).with(user.id, 'file.csv').and_return mailer
        expect(mailer).to receive(:deliver_later)
        perform
      end
    end
  end
end
