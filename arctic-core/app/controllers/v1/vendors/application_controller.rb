# frozen_string_literal: true

class V1::Vendors::ApplicationController < V1::ApplicationController #:nodoc:
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :authenticate_vendor!

  before_action :set_paper_trail_whodunnit

  private

    def user_for_paper_trail
      "Vendor(#{current_vendor.id})"
    end

    def authenticate_vendor!
      @current_vendor = authenticate_or_request_with_http_basic do |id, token|
        Vendor.find_by(id: id, token: token)
      end || raise(HttpError::Unauthorized, 'Invalid Authorization header')
    end

    def current_vendor
      @current_vendor || raise(HttpError::InternalServerError, 'Missing current_vendor')
    end
    alias rollbar_user current_vendor
end
