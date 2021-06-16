# frozen_string_literal: true

class Array #:nodoc:
  def deep_symbolize_keys
    map(&:deep_symbolize_keys)
  end

  def deep_stringify_keys!
    map(&:deep_stringify_keys!)
  end

  def deep_stringify_keys
    map(&:deep_stringify_keys)
  end

  def except(*value)
    self - [value].flatten
  end
end
