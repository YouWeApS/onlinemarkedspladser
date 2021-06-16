# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Currencies', swagger_doc: 'v1/ui/swagger.json' do
  path '/v1/ui/currencies' do
    include_context :swagger_authenticated_user

    get 'list available currencies' do
      tags 'Currency and Pricing'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/currencies')
        end
      end
    end
  end
end
