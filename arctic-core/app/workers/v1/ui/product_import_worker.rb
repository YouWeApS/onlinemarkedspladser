# frozen_string_literal: true

class V1::Ui::ProductImportWorker
  include Sidekiq::Worker

  sidekiq_options \
    queue: :product_imports,
    backtrace: true,
    unique: :until_executed

  attr_reader :path, :saved, :vendor, :shop, :user

  def perform(user_id, vendor_id, shop_id, path)
    @user = User.find user_id
    @shop = user.shops.find shop_id
    @vendor = shop.vendors.find vendor_id
    @path = path
    process
  ensure
    FileUtils.rm path if File.exist? path
  end

  private

    def process
      store_to_s3
      process_import
      notify_user
    end

    def process_import
      @saved = ProductImport.new(vendor, shop, path).save
    end

    def notify_user
      if saved
        V1::Ui::ProductImportMailer.completed(user.id, filename).deliver_later
      else
        V1::Ui::ProductImportMailer.failed(user.id, filename).deliver_later
      end
    end

    def store_to_s3
      s3_url = S3Uploader
        .new("#")
        .upload(path)
        .url_for(path)

      Rails.logger.info "Stored import file #{filename} in #{s3_url}"
    end

    def filename
      @filename ||= File.basename path
    end
end
