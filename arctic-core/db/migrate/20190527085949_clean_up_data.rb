class CleanUpData < ActiveRecord::Migration[5.2]
  def up
    Dispersal.only_deleted.each {|d| d.really_destroy! }
    OrderLine.only_deleted.each {|d| d.really_destroy! }
    RawProductData.only_deleted.each {|d| d.really_destroy! }
    ShadowProduct.only_deleted.each {|d| d.really_destroy! }
    VendorProductMatch.only_deleted.each {|d| d.really_destroy! }
    ProductImage.only_deleted.each {|d| d.really_destroy! }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
