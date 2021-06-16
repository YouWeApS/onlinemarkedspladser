# frozen_string_literal: true

require 'digest'

class DeduplicateRawProductData < ActiveRecord::Migration[5.2]
  def up
    kept_records = []
    records_to_destroy = []

    RawProductData.find_each do |raw_product_data|
      md5 = Digest::MD5.hexdigest raw_product_data.data.to_s
      id = "#{raw_product_data.product_id}:#{md5}"

      if kept_records.include? id
        records_to_destroy << raw_product_data.id
      else
        kept_records << id
      end
    end

    # This is faster than deleting then one by one.
    # There's currently no destroy callbacks for the record, so it's safe to
    # call delete.
    RawProductData.where(id: records_to_destroy).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
