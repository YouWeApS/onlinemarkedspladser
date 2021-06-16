# frozen_string_literal: true

FactoryBot.define do
  factory :vendor_shop_collection_configuration,
    parent: :vendor_shop_configuration,
    class: 'VendorShopCollectionConfiguration' do
    type { 'VendorShopCollectionConfiguration' }
  end
end
