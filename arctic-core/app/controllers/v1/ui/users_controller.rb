# frozen_string_literal: true

class V1::Ui::UsersController < V1::Ui::ApplicationController #:nodoc:
  def update
    doorkeeper_authorize! :'user:write'
    update_user
    render json: V1::Ui::UserBlueprint.render(current_user)
  end

  def show
    doorkeeper_authorize! :'user:read'
    render json: V1::Ui::UserBlueprint.render(current_user)
  end

  private

    def user_params
      params.permit \
        :email,
        :password,
        :password_confirmation,
        :name,
        :locale
    end

    def update_user
      current_user.attributes = user_params
      current_user.avatar.attach params[:avatar] if params[:avatar]
      current_user.save!
    end
end
