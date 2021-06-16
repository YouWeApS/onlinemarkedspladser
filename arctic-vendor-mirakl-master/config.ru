# frozen_string_literal: true

require_relative './lib/mirakl'

run Rack::URLMap.new \
  '/' => Arctic::ValidationApi,
  '/sidekiq' => Sidekiq::Web
