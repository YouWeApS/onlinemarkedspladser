# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Shops', swagger_doc: 'v1/ui/swagger.json' do
  path '/v1/ui/accounts/{account_id}/shops/' do
    include_context :swagger_authenticated_user, scopes: 'product:read'

    let(:account) { create :account, users: [user] }
    let!(:shops) { create_list :shop, 2, account: account }

    parameter \
      name: :account_id,
      in: :path,
      type: :string,
      required: true,
      description: 'Account ID'
    let(:account_id) { account.id }

    get 'list shops for account' do
      tags 'Shops'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[product:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/shops')
        end
      end
    end
  end
end
