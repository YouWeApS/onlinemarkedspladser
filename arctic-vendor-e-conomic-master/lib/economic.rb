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
  config.host = ENV.fetch 'HOST', 'economic'
end

require 'pathname'

$root = Pathname.new File.expand_path('..', __dir__)
$LOAD_PATH.unshift File.expand_path __dir__

require_relative '../config/sidekiq.rb'

log_file = $root.join('log', "#{environment}.log")

FileUtils.mkdir_p $root.join('log')
FileUtils.touch log_file

Arctic.logger = Logger.new log_file
Arctic.logger.level = Logger::INFO

module Economic
  VERSION = File.read($root.join('VERSION')).chomp

  autoload :V1, 'economic/v1'
end
