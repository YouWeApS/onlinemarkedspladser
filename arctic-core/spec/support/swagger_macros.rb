# frozen_string_literal: true

RSpec.shared_context :swagger_authenticated_vendor do
  let(:vendor) { create :vendor }
  let(:auth_hash) { ::Base64.strict_encode64("#{vendor.id}:#{vendor.token}") }
  let(:Authorization) { "Basic #{auth_hash}" }
end

RSpec.shared_context :swagger_authenticated_user do |scopes: []|
  let(:user) { create :user }
  let(:token) { user.access_tokens.create! scopes: [scopes].flatten.join(' ') }
  let(:Authorization) { "Bearer #{token.token}" }
end
