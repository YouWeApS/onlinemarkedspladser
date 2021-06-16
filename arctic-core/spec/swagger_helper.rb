# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.swagger_dry_run = false

  config.after(example: true) do |example|
    example.metadata[:response][:examples] = {
      'application/json' => begin
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError
        {}
      end,
    }
  end

  config.swagger_root = Rails.root.join('public', 'swagger').to_s

  vendor_doc_description = <<~STR.strip_heredoc
    Vendor documentation is targeted to developers building vendor integrations to the Arctic project.

    Authenticate with `VENDOR_ID` and `VENDOR_TOKEN`

  STR

  ui_doc_description = <<~STR.strip_heredoc
    UI documentation is targeted towards User interfaces build to interact with the Arctic system.

    This uses OAuth2 authentication.
  STR

  config.swagger_docs = {
    'v1/vendors/swagger.json' => {
      swagger: '2.0',

      info: {
        title: 'Vendor API',
        version: 'v1',
        description: vendor_doc_description,
      },

      securityDefinitions: {
        basic: {
          type: :basic,
        },
      },
    },

    'v1/ui/swagger.json' => {
      swagger: '2.0',

      info: {
        title: 'UI API',
        version: 'v1',
        description: ui_doc_description,
      },

      securityDefinitions: {
        oauth2: {
          flow: :accessCode,
          type: :oauth2,
          authorizationUrl: '/v1/ui/oauth/authorize',
          tokenUrl: '/v1/ui/oauth/token',
          scopes: {
            'user:read': 'Access to basic user information',
            'user:write': 'Access to detailed user information and ability to update information',

            'product:read': 'Access to read product information',
            'product:write': 'Access to write and update product information',

            'order:read': 'Access to read order information',
            'order:write': 'Access to write and update order information',
          },
        },
      },
    },
  }
end
