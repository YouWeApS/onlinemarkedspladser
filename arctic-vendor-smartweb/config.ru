# frozen_string_literal: true

require_relative './lib/smartweb'

run Rack::URLMap.new '/sidekiq' => Sidekiq::Web
