# frozen_string_literal: true

class ApplicationCable::Connection < ActionCable::Connection::Base #:nodoc:
  identified_by :current_user

  def connect
    self.current_user = find_verified_user
    logger.add_tags 'ActionCable', request.uuid, "User(#{current_user.id})"
  end

  private

    def find_verified_user
      access_token = request.params[:access_token]
      logger.warn 'Missing access_token' if access_token.to_s.strip.blank?
      User.find Doorkeeper::AccessToken.by_token(access_token).try(:resource_owner_id)
    rescue ActiveRecord::RecordNotFound
      reject_unauthorized_connection
    end
end
