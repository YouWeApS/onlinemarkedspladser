# frozen_string_literal: true

require_relative './lib/economic'

run Rack::URLMap.new '/sidekiq' => Sidekiq::Web
