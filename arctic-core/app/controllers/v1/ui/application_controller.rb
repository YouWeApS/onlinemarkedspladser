# frozen_string_literal: true

class V1::Ui::ApplicationController < V1::ApplicationController #:nodoc:
  before_action :doorkeeper_authorize!

  before_action :set_i18n_locale

  before_action :set_paper_trail_whodunnit

  private

    def user_for_paper_trail
      "User(#{current_user.id})"
    end

    def current_user
      return @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def current_account
      @current_account ||= current_user
        .accounts
        .find params.fetch(:account_id, params[:id])
    end

    def current_shop
      @current_shop ||= current_account
        .shops
        .find params.fetch(:shop_id, params[:id])
    end

    def current_vendor(type = nil)
      @current_vendor ||= begin
        vendor_id = params[:vendor_id].presence || params[:id].presence
        vendor_collection(type).find vendor_id
      end
    end

    def vendor_collection(type)
      case type
      when :dispersal then current_shop.dispersal_vendors
      when :collection then current_shop.collection_vendors
      else current_shop.vendors
      end
    end

    def current_vendor_config
      @current_vendor_config ||= current_shop.vendor_config_for current_vendor
    end

    def set_i18n_locale
      locale = I18n.default_locale
      locale = current_user.locale if I18n.available_locales.include?(current_user.locale)
      locale ||= :en
      I18n.locale = locale
    end
end
