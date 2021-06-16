# frozen_string_literal: true

require 'dotenv'
Dotenv.load
environment = ENV.fetch('RACK_ENV', 'development')

require 'bundler/setup'
Bundler.require :default, environment

require 'rollbar'
Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.environment = ENV.fetch 'RACK_ENV', 'development'
  config.host = ENV.fetch 'HOST', 'dandomain'
end

require 'pathname'

$root = Pathname.new File.expand_path('..', __dir__)
$LOAD_PATH.unshift $root.join('lib').to_s

log_file = $root.join('log', "#{environment}.log")
FileUtils.mkdir_p $root.join('log')
FileUtils.touch log_file
Arctic.logger = Logger.new log_file
Arctic.logger.level = Logger::INFO

port = ENV.fetch('REDIS_PORT', '6380')

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:#{port}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:#{port}" }
end

# For this project log to file
logger = Logger.new File.expand_path('../log/sidekiq.log', __dir__)
logger.formatter = Ruby::JSONFormatter::Base.new ENV.fetch('HOST', 'no-host')

Sidekiq.logger = logger
Sidekiq.logger.level = Logger::DEBUG

module Dandomain
  VERSION = File.read($root.join('VERSION')).chomp

  autoload :V2, 'dandomain/v2'
end
