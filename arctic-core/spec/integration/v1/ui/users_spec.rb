# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Users', swagger_doc: 'v1/ui/swagger.json' do
  path '/v1/ui/me' do
    include_context :swagger_authenticated_user, scopes: 'user:read'

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'User ID'
    let(:id) { user.id }

    get 'user information' do
      tags 'Users'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[user:read] ]

      response 200, 'Success', example: true do
        run_test! do |response|
          expect(response).to match_response_schema('ui/user')
        end
      end
    end
  end

  path '/v1/ui/users/{id}' do
    include_context :swagger_authenticated_user, scopes: 'user:write'
    let(:id) { user.id }

    parameter \
      name: :id,
      in: :path,
      type: :string,
      required: true,
      description: 'User ID'

    patch 'update user information' do
      tags 'Users'

      consumes 'application/json'
      produces 'application/json'

      security [ oauth2: %w[user:write] ]

      parameter \
        name: :body,
        in: :body,
        required: true,
        schema: {
          type: :object,
          anyOf: [
            { required: %i[password, password_confirmation] },
            { required: %i[email] },
          ],
          properties: {
            email: {
              type: :string,
            },
            password: {
              type: :string,
            },
            password_confirmation: {
              type: :string,
            },
          },
        }

      let(:body) do
        {
          email: 'another@email.com',
        }
      end

      response 200, 'Success', example: true do
        run_test! do |response|
          json = JSON.parse response.body
          expect(json.dig('email')).to eql('another@email.com')
        end
      end
    end
  end
end
