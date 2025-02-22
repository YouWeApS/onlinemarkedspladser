# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CoreApi #:nodoc:
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    # config.api_only = true

    # Server should run in UTC
    config.time_zone = 'UTC'

    # Add autoload paths
    config.enable_dependency_loading = true
    config.autoload_paths << Rails.root.join('app', 'product_formatters')
    config.autoload_paths << Rails.root.join('lib')

    # Prepend all log lines with the following tags.
    config.log_tags = %i[request_id]

    # Set schema format to sql
    config.active_record.schema_format = :sql

    config.generators do |g|
      g.helper false
      g.assets false
      g.template_engine false
    end

    redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379')

    config.cache_store = :redis_store, redis_url, {
      expires_in: 30.minutes,
    }
  end
end

# rubocop:enable Style/ClassAndModuleChildren
