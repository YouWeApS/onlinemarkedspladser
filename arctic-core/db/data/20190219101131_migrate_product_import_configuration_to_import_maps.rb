class MigrateProductImportConfigurationToImportMaps < ActiveRecord::Migration[5.2]
  def up
    VendorShopCollectionConfiguration.find_each do |config|
      config.product_parse_config.each do |field, hash|
        default = hash['default'].presence
        source = hash['source'].presence
        value = hash['value'].presence
        variations = hash['variation'].to_s.split(',')

        if variations.any?
          variations.each do |variation|
            im = config.import_maps.new \
              to: field,
              default: default,
              from: variation.presence,
              regex: value

            im.save if im.valid?
          end
        else
          im = config.import_maps.new \
            to: field,
            default: default,
            from: source,
            regex: value

          im.save if im.valid?
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
