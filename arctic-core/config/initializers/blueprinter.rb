# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

require 'oj'

Blueprinter.configure do |config|
  config.generator = Oj # default is JSON
end

module Blueprinter
  class Base
    DATE_FORMAT = '%a, %d %b %Y %H:%M:%S %Z'
  end
end

# rubocop:enable Style/ClassAndModuleChildren
