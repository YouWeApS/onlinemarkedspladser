# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::UsersController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let!(:user) { create :user }

  describe '#show' do
    let(:action) { get :show }

    it_behaves_like :http_status, 401

    context 'authenticated with invalid scope' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated' do
      include_context :authenticated, scopes: 'user:read'

      it { expect(action).to match_response_schema 'ui/user' }
    end
  end

  describe '#update' do
    let(:action) { put :update, params: params }

    let(:params) do
      {
        id: user.id,
        email: 'my-new@email.com',
        locale: :da,
      }
    end

    it_behaves_like :http_status, 401

    context 'authenticated with invalid scope' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated' do
      include_context :authenticated, scopes: 'user:write'

      it { expect { action }.to change { user.reload.email }.to('my-new@email.com') }

      it { expect { action }.to change { user.reload.locale }.from('en').to('da') }

      it { expect(action).to match_response_schema 'ui/user' }

      describe 'attaching avatar' do
        before do
          params[:avatar] = fixture_file_upload \
            Rails.root.join('spec', 'fixtures', 'images', 'mathilde.jpg'),
            'image/jpg'
        end

        it 'stores the avatar in ActiveStorage' do
          expect { action }.to change(ActiveStorage::Attachment, :count).by(1)
        end

        it 'responds with the attached avatar url' do
          action
          expect(JSON.parse(response.body)['avatar_url']).to be_present
        end
      end
    end
  end
end
