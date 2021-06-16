# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UI Recover password', swagger_doc: 'v1/ui/swagger.json' do
  path '/v1/ui/reset_password' do
    let!(:user) { create :user, password_reset_token: 'abcdef123' }

    post 'reset password' do
      tags 'Users'

      consumes 'application/json'
      produces 'application/json'

      parameter \
        name: :body,
        in: :body,
        type: :object,
        required: true,
        description: 'Password reset information',
        schema: {
          required: %i[token],
          properties: {
            token: {
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
          token: 'abcdef123',
          password: 'new-secure-password',
          password_confirmation: 'new-secure-password',
        }
      end

      response 205, 'Success', example: true do
        run_test!
      end
    end
  end

  path '/v1/ui/recover_password' do
    let(:user) { create :user }

    post 'start recovery flow' do
      tags 'Users'

      consumes 'application/json'
      produces 'application/json'

      parameter \
        name: :body,
        in: :body,
        type: :object,
        required: true,
        description: 'Post body',
        schema: {
          required: %i[email redirect_to],
          properties: {
            email: {
              type: :string,
            },
            redirect_to: {
              type: :string,
            },
          },
        }

      let(:body) do
        {
          email: user.email,
          redirect_to: 'https://google.com',
        }
      end

      response 202, 'Success', example: true do
        run_test!
      end
    end
  end
end
