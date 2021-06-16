# frozen_string_literal: true

class ProductBroadcast
  attr_reader :shadow

  def initialize(shadow)
    @shadow = shadow
  end

  def self.broadcast(product)
    raise ArgumentError, 'you must supply a Product' unless product.is_a? Product

    product.shadow_products.each do |shadow|
      ProductBroadcast.new(shadow).broadcast
    end
  end

  def broadcast
    shadow.product.shop.account.users.find_each do |user|
      broadcast_to_user user
    end
  end

  private

    def broadcast_to_user(user)
      Rails.logger.info "Broadcasting ShadowProduct(#{shadow.id}) to User(#{user.id})"
      ProductsChannel.broadcast_to user.id, json
    end

    def json
      @json ||= ProductCache.fetch shadow do
        V1::Ui::ProductBlueprint.render_as_hash shadow, vendor: shadow.vendor
      end
    end
end
