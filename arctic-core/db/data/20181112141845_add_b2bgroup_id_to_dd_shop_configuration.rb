class AddB2bgroupIdToDdShopConfiguration < ActiveRecord::Migration[5.2]
  def up
    dd_channel = Channel.find_by name: 'Dandomain'

    return unless dd_channel

    dd_channel.config_schema ||= {}
    dd_channel.config_schema['properties'] ||= {}
    dd_channel.config_schema['properties']['b2b_group_id'] = {
      title: 'Price B2B group ID',
      type: :string,
    }
    dd_channel.save!

    dd_channel.vendors.each do |vendor|
      vendor.collection_shops.each do |shop|
        config = shop.vendor_config_for vendor
        config.config['b2b_group_id'] = '-2' # b2c - http://bit.ly/2QAnyKR
        config.save!
      end
    end
  end

  def down
    dd_channel = Channel.find_by name: 'Dandomain'
    dd_channel.config_schema['properties'].delete 'b2b_group_id'
    dd_channel.save!
  end
end
