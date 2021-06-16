# frozen_string_literal: true

class ApplicationController < ActionController::Base #:nodoc:
  def current_user
    @current_user ||= SessionToken.find(session[:session_token]).user
  rescue ActiveRecord::RecordNotFound
    nil
  end

  alias rollbar_user current_user
end
