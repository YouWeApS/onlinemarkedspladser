require 'rails_helper'

RSpec.describe V1::Ui::ImportMapsController, type: :controller do
  let!(:user) { create :user, accounts: [config.shop.account] }
  let(:config) { create :vendor_shop_configuration }
  let(:params) do
    {
      account_id: config.shop.account.id,
      shop_id: config.shop.id,
      vendor_id: config.vendor.id,
    }
  end

  describe '#create' do
    before do
      params.merge! \
        from: 'description.description',
        to: 'description',
        regex: '.+',
        default: 'Black'
    end

    let(:action) { post :create, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'
      it { expect { action }.to change { config.import_maps.count }.by(1) }

      it 'has the right information' do
        action
        expect(ImportMap.last.attributes.slice('from', 'to', 'regex', 'default')).to eql \
          'from' => 'description.description',
          'to' => 'description',
          'regex' => '.+',
          'default' => 'Black'
      end
    end
  end

  describe '#update' do
    let(:import_map) { create :import_map, vendor_shop_configuration: config }

    before do
      params.merge! \
        id: import_map.id,
        from: 'description.description',
        to: 'description',
        regex: '.+',
        default: 'Black'
    end

    let(:action) { patch :update, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it { expect { action }.to change { import_map.reload.from }.from('MyString').to('description.description') }
    end
  end

  describe '#destroy' do
    let(:import_map) { create :import_map, vendor_shop_configuration: config }

    before { params.merge! id: import_map.id }

    let(:action) { delete :destroy, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it { expect { action }.to change { config.import_maps.count }.by(-1) }
    end
  end
end
