# frozen_string_literal: true

class V1::Ui::ChannelBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :name, :auth_config_schema, :config_schema, :category_map_json_schema

  field :webhook_schema do
    V1::WebhookSchema::SCHEMA
  end
end
