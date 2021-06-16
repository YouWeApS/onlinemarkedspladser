# frozen_string_literal: true

class CategoryMap < ApplicationRecord #:nodoc:
  acts_as_list scope: %i[source vendor_shop_configuration_id]

  belongs_to :vendor_shop_configuration

  has_one :shop, through: :vendor_shop_configuration
  has_one :vendor, through: :vendor_shop_configuration
  has_one :channel, through: :vendor

  validates :source, presence: true
  validates :value, presence: true

  after_save :update_products_after_creating

  def schema
    channel.category_map_json_schema
  end

  private

    def update_products_after_creating
      vendor.shadow_products.where('categories::text = ?', [source].to_s)&.map { |a| a.touch }
    end
end
