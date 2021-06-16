require "rails_helper"

class V1::Ui::Tests::ApplicationControllerSpec < V1::Ui::Tests::ApplicationController
  def index; end
end

RSpec.describe V1::Ui::Tests::ApplicationControllerSpec, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  before(:context) do
    Rails.application.routes.draw do
      get 'spec/v1/ui/tests/application_controller_spec',
        to: 'v1/ui/tests/application_controller_spec#index'
    end
  end

  after(:context) do
    Rails.application.reload_routes!
  end

  let(:action) { get :index }
  let(:user) { create :user }

  describe 'authentication' do
    it_behaves_like :http_status, 401

    context 'authenticated' do
      include_context :authenticated

      it_behaves_like :http_status, 204
    end
  end
end
