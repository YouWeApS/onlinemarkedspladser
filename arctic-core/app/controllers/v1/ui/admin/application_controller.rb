# frozen_string_literal: true

class V1::Ui::Admin::ApplicationController < V1::Ui::ApplicationController
  before_action :authorize_admin

  private

    def authorize_admin
      doorkeeper_authorize! 'admin'
    end
end
