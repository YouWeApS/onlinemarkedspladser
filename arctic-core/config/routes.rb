# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq_unique_jobs/web'

def draw_routes(routes_name)
  instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
end

# Protect with password in prod
if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username_match = ActiveSupport::SecurityUtils.secure_compare \
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])

    password_match = ActiveSupport::SecurityUtils.secure_compare \
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'])

    username_match & password_match
  end
end

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => 'docs'

  mount Sidekiq::Web => '/sidekiq'

  # https://github.com/ianheggie/health_check
  health_check_routes

  draw_routes :v1

  root to: redirect('/docs')
end
