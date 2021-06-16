# frozen_string_literal: true
# run task and not execute:    rake fix_sync_task:cleanup
#
# run task and execute:    rake fix_sync_task:cleanup execute=true
#
namespace :fix_sync_task do
  desc 'Fix wrong data in shadow products'
  task cleanup: :environment do
    puts "run clean up, execute #{ENV['execute']}"
    puts "deleted shadow_products:"

    dup_products = ShadowProduct.select(:product_id, :vendor_shop_configuration_id)
                       .group(:product_id, :vendor_shop_configuration_id).having("count(*) > 1")
                       .with_deleted.pluck(:product_id,:vendor_shop_configuration_id)
    dup_products.each do |product_id, vendor_shop_configuration_id|
      products_destroy = ShadowProduct.where(product_id: product_id, vendor_shop_configuration_id: vendor_shop_configuration_id)
        .with_deleted.order(updated_at: :asc)
      products_destroy[1..-1].map do |destroyed_product|
        puts destroyed_product.id
        master = destroyed_product.product.master? ? destroyed_product.product : destroyed_product.product.master
        destroyed_product.really_destroy! if ENV['execute']

        #remove product from variants_id
        shadow_products = ShadowProduct.with_deleted.where(vendor_shop_configuration_id: vendor_shop_configuration_id)
        shadow_variants = shadow_products.where(product: master.variants)
                              .or(shadow_products.where(product: master))

        variants_ids = shadow_variants.pluck(:id)
        shadow_variants.update_all(variant_ids: variants_ids) if ENV['execute']
      end
    end

    puts "set empty master_id for shadow_products:"
    # set empty master_id for shadow_products
    shadows = ShadowProduct.joins(:product).with_deleted.where(master_id: nil).where.not(products: {master_sku: nil}).uniq
    shadows.each do |par|
      shadow_master_id = par.product.master.shadow_products.with_deleted
                             .where(vendor_shop_configuration_id: par.vendor_shop_configuration_id).take.id
      puts shadow_master_id
      par.update_attribute(:master_id, shadow_master_id) if ENV['execute']
    end
  end
end

