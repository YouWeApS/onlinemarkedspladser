# frozen_string_literal: true

class V1::Ui::AccountsController < V1::Ui::ApplicationController #:nodoc:
  def index
    doorkeeper_authorize! :'user:write'
    render json: V1::Ui::AccountBlueprint.render(accounts) if http_stale?
  end

  private

    def last_modified
      @last_modified ||= accounts.maximum(:updated_at)
    end

    def accounts
      @accounts ||= current_user.accounts
    end

    def http_stale?
      stale? etag: accounts, last_modified: last_modified
    end
end
