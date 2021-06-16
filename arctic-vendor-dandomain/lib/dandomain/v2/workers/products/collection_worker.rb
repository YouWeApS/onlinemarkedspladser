# Syncs products from DD -> Core API
class Dandomain::V2::Workers::Products::CollectionWorker
  include Sidekiq::Worker

  # Blocks running multiple synchronizations ot the same shop at the same time
  sidekiq_options lock: :until_and_while_executing

  attr_reader :shop_id

  def perform(shop_id)
    @shop_id = shop_id

    Arctic.logger.info "Collecting products since #{last_synced_at} from Shop(#{shop_id}) -> Core API"

    dd_api.products(modifiedStartDate: last_synced_at) do |product|
      begin
        puts product.inspect
        core_api.create_product shop_id, product if product.present?
      rescue => e
        Arctic.logger.debug "Unable to create product (#{e.class}): #{e.message}"
      end
    end

    core_api.synced shop_id, :products
  end

  private

    def last_synced_at
      @last_synced_at ||= core_api.last_synced_at shop_id, :products
    end

    def core_api
      @core_api ||= Arctic::Vendor::API.new
    end

    def shop
      @shop ||= core_api.get_shop shop_id
    end

    def dd_api
      @dd_api ||= Dandomain::V2::API.new shop
    end
end
