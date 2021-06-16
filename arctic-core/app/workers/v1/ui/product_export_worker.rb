# frozen_string_literal: true

require 'product_export'

class V1::Ui::ProductExportWorker
  include Sidekiq::Worker

  sidekiq_options \
    queue: :product_exports,
    backtrace: true,
    unique: :until_executed

  def perform(user_id, vendor_id, shop_id)
    vendor = Vendor.find vendor_id
    shop = Shop.find shop_id

    export = ::ProductExport.new vendor, shop
    export.generate

    V1::Ui::ProductExportMailer.send_link(user_id, export.url).deliver_later
  end
end
