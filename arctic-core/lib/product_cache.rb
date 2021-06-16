# frozen_string_literal: true

class ProductCache
  class << self
    def write(shadow_or_product)
      if shadow_or_product.is_a? Product
        shadow_or_product.shadow_products.each { |s| write s }
      else
        V1::Ui::ProductBlueprint.render_as_hash(
          shadow_or_product,
          vendor: shadow_or_product.vendor
        ).tap do |json|
          Rails.cache.write [shadow_or_product.vendor.id, shadow_or_product.id], json
        end
      end
    end

    def clear(shadow_products)
      raise ArgumentError, 'only available for ShadowProduct instances' if shadow_products.any? { |s| s.is_a? Product }

      shadow_products.each do |shadow|
        Rails.cache.delete [shadow.vendor.id, shadow.id]
      end
    end

    def fetch(shadow_or_product, vendor = nil)
      if shadow_or_product.is_a? Product
        shadow_or_product.shadow_products.each { |s| fetch s, vendor }
      else
        vendor ||= shadow_or_product.vendor
        Rails.cache.fetch [vendor.id, shadow_or_product.id] do
          yield if block_given?
        end
      end
    end
  end
end
