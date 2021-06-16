# frozen_string_literal: true
class UpdateChannelConfig < ActiveRecord::Migration[5.2]

  PROP = {
      title: 'CDON order report URL',
      type: :string,
      format: :presence,
  }.freeze

  def up
    Channel.where("name ~ 'CDON'").find_each do |c|
      c.config_schema['required'] ||= []
      c.config_schema['properties'] ||= {}
      c.config_schema['required'] << 'report_id'
      c.config_schema['required'].uniq
      c.config_schema['properties'][:report_id] = PROP
      c.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end