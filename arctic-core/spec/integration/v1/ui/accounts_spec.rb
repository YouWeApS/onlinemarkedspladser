# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Accounts', swagger_doc: 'v1/ui/swagger.json' do
  path '/v1/ui/accounts/' do
    include_context :swagger_authenticated_user, scopes: 'user:write'

    let!(:accounts) { create_list :account, 2, users: [user] }

    get 'list accounts' do
      tags 'Accounts'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[user:write] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/accounts')
        end
      end
    end
  end
end
