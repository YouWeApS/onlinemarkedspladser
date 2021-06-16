# frozen_string_literal: true

require 'json-schema'

# JSON schema UUID format validator
uuid_proc = lambda do |value|
  raise JSON::Schema::CustomFormatError, 'must be a valid UUID' unless value.to_s.match RubyRegex::UUID
end
JSON::Validator.register_format_validator('uuid', uuid_proc)

# JSON schema URL format validator
url_proc = lambda do |value|
  raise JSON::Schema::CustomFormatError, "must be a valid URL (#{value})" unless value.match RubyRegex::Url
end
JSON::Validator.register_format_validator('url', url_proc)

# JSON schema string presence validator
string_presence = lambda do |value|
  raise JSON::Schema::CustomFormatError, 'must have a value' if value.to_s.strip.blank?
end
JSON::Validator.register_format_validator('presence', string_presence)

# JSON schema HTTP date format validator
date_proc = lambda do |value|
  if value.to_s.present? && !value.to_s.match(RubyRegex::HttpDate)
    raise JSON::Schema::CustomFormatError, "(#{value}) must be a valid HTTP-Date-style datetime"
  end
end
JSON::Validator.register_format_validator('datetime', date_proc)
