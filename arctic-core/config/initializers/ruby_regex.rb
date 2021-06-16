# frozen_string_literal: true

# rubocop:disable Naming/ConstantName
# rubocop:disable Style/RegexpLiteral

module RubyRegex
  # Enhance URL matcher to allow a port in the address and make tld optional (to
  # allow localhost)
  Url = URL = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\:\d+)*(\.[a-z]{2,5})*(([0-9]{1,5})?\/.*)?\z/ix

  HttpDate = /\A\w{3}, \d{2} \w{3} \d{4} \d{2}:\d{2}:\d{2} \w{3}\z/
end

# rubocop:enable Naming/ConstantName
# rubocop:enable Style/RegexpLiteral
