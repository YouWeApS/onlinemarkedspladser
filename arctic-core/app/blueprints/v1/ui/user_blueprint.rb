# frozen_string_literal: true

class V1::Ui::UserBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :email, :name, :locale

  field :password_updated, if: ->(user, _) { user.password_confirmation.present? } do |user|
    user.password == user.password_confirmation
  end

  field :avatar_url do |user|
    begin
      if user.avatar.attached?
        Rails.application.routes.url_helpers.rails_blob_url(user.avatar).tap do |url|
          url.gsub! 'http:', 'https:' if Rails.env.production?
        end
      end
    rescue
      nil
    end
  end
end
