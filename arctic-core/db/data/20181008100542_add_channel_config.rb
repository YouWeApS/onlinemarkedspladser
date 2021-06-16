# frozen_string_literal: true

class AddChannelConfig < ActiveRecord::Migration[5.2]
  SCHEMA = {
    type: :object,
    required: %w[
      host
      site_id
    ],
    properties: {
      host: {
        title: 'Dandomain site URL',
        type: :string,
        format: :url,
      },
      site_id: {
        title: 'Dandomain site ID',
        type: :number,
        format: :presence,
      },
    },
  }.freeze

  def up
    Channel.where("name ~ 'Dandomain'").find_each do |c|
      c.update config_schema: SCHEMA
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
