# frozen_string_literal: true

# rubocop:disable Style/AccessModifierDeclarations

require 'arctic/vendor'

module Amazon
  def logger=(logger)
    @logger = logger
  end

  module_function :logger=

  def logger
    @logger || Arctic.logger
  end

  module_function :logger
end

# For this project log to file
logger = Logger.new File.expand_path('../../log/amazon.log', __dir__)
logger.formatter = Ruby::JSONFormatter::Base.new ENV.fetch('HOST', 'no-host')

Arctic.logger = logger

# rubocop:enable Style/AccessModifierDeclarations
