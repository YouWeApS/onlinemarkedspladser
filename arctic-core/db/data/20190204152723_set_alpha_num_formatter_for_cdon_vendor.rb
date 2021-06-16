class SetAlphaNumFormatterForCdonVendor < ActiveRecord::Migration[5.2]
  def up
    Vendor.find('1b54b7de-509b-498a-83fb-7fe050511236')
      .update sku_formatter: 'AlphaNumSku'
  rescue => e
    Rails.logger.error "Unable to update sku formatter for CDON vendor (#{e.class}): #{e.message}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
