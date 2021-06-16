# frozen_string_literal: true

require 'rails_helper'

class UiTestController < V1::Ui::ApplicationController
  def index
    render json: {
      current_user: current_user.id,
      current_account: current_account.id,
      current_shop: current_shop.id,
      current_vendor: current_vendor.id,
      current_vendor_config: current_vendor_config.id,
    }
  end
end

RSpec.describe UiTestController, type: :controller do
  before(:context) do
    Rails.application.routes.draw do
      get 'accounts/:account_id/shops/:shop_id/vendors/:vendor_id', to: 'ui_test#index'
    end
  end

  after(:context) do
    Rails.application.reload_routes!
  end

  let(:account) { create :account }
  let(:shop) { create :shop, account: account }
  let(:vendor) { create :vendor }
  let(:user) { create :user, accounts: [account] }
  let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

  let(:params) do
    {
      account_id: account.id,
      shop_id: shop.id,
      vendor_id: vendor.id,
    }
  end

  let(:action) { get :index, params: params }

  describe 'authentication' do
    it_behaves_like :http_status, 401

    context 'authenticated' do
      include_context :authenticated

      it_behaves_like :http_status, 200
    end
  end
end
