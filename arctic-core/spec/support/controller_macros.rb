# frozen_string_literal: true

module ControllerExamples
  RSpec.shared_examples :unauthenticated do
    before { action }
    it { expect(response.status).to eql 401 }
    it { expect(response.body.chomp).to eql 'HTTP Basic: Access denied.' }
  end

  RSpec.shared_examples :http_status do |expected_status|
    before { action }
    it { expect(response.status).to eql expected_status }
  end

  RSpec.shared_examples :include_in_response_body do |string|
    before { action }
    it { expect(response.body).to match string }
  end

  RSpec.shared_examples :response_body do |hash|
    before { action }
    it { expect(response.body).to eql(hash.to_json) }
  end

  RSpec.shared_examples :paginated do
    before { action }
    it { expect(response.headers['Per-Page']).to be_present }
    it { expect(response.headers['Total']).to be_present }
  end

  RSpec.shared_examples :admin_authenticated_endpoint do |scopes: 'admin:account:read'|
    it_behaves_like :http_status, 401

    context 'authenticated with missing scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated with out admin scope' do
      include_context :authenticated, scopes: scopes

      it_behaves_like :http_status, 403
    end
  end
end

module ControllerContext
  RSpec.shared_context :authenticated_admin do |scopes: ''|
    before { scopes = 'admin ' + scopes }

    let(:token) { user.access_tokens.create! scopes: scopes }

    before do
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{token.token}"
    end
  end

  RSpec.shared_context :authenticated do |scopes: ''|
    let(:token) { user.access_tokens.create! scopes: scopes }

    before do
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{token.token}"
    end
  end

  RSpec.shared_context :authenticated_vendor do
    let(:vendor) { create :vendor }

    before do
      hash = ActionController::HttpAuthentication::Basic.encode_credentials(vendor.id, vendor.token)
      request.env['HTTP_AUTHORIZATION'] = hash
    end
  end
end

RSpec.configure do |config|
  config.include ControllerExamples, type: :controller
  config.include ControllerContext, type: :controller
end
