class RemoveMarketplaceIdFromVendors < ActiveRecord::Migration[5.2]
  def up
    Channel.find_each do |c|
      schema = c.auth_config_schema || {}
      schema.fetch('required', {}).delete 'marketplace'
      schema.fetch('properties', {}).delete 'marketplace'
      c.update auth_config_schema: schema
    end
    VendorShopConfiguration.find_each do |c|
      auth_config = c.auth_config || {}
      auth_config.delete 'marketplace'
      c.update auth_config: auth_config
    end
  end

  def down
  end
end
