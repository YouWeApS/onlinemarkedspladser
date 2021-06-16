# frozen_string_literal: true

class V1::Ui::ShopsController < V1::Ui::ApplicationController #:nodoc:
  def index
    doorkeeper_authorize! :'product:read'
    render json: json if render?
  end

  private

    def current_account
      @current_account ||= current_user.accounts.find params[:account_id]
    end

    def shops
      @shops ||= current_account.shops
    end

    def last_modified
      @last_modified ||= shops.maximum(:updated_at)
    end

    def render?
      stale? etag: shops, last_modified: last_modified
    end

    def json
      V1::Ui::ShopBlueprint.render shops
    end
end
