# frozen_string_literal: true

class V1::Ui::Admin::AccountsController < V1::Ui::Admin::ApplicationController
  def index
    doorkeeper_authorize! 'admin:account:read'
    render_accounts if render_accounts?
  end

  def create
    doorkeeper_authorize! 'admin:account:write'
    render_account if create_account
  end

  private

    def create_account
      @account = Account.create! account_params
    end

    def render_account
      render json: V1::Ui::Admin::AccountBlueprint.render(account)
    end

    def account
      @account ||= Account.find params[:id]
    end

    def render_accounts
      render json: V1::Ui::Admin::AccountBlueprint.render(accounts)
    end

    def render_accounts?
      last_modified = accounts.maximum :updated_at
      stale? etag: accounts, last_modified: last_modified
    end

    def accounts
      @accounts ||= Account.all
    end

    def account_params
      params.permit(:name)
    end
end
