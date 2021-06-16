# frozen_string_literal: true

class Sku #:nodoc:
  attr_reader :sku

  def initialize(sku)
    @sku = sku
  end

  def to_s
    s = sku.to_s
    s = s.strip # remove leading and trailing whitespace
    s = s.delete('.') # router can't handle dots
    s = s.delete('#') # router can't handle #s
    s = s.gsub(/(2B)+/, '') # delete repeat of 2B, which was previously a bug
    s = s.gsub(/[^a-zA-Z0-9\-\_]+/, ' ') # delete everything not alphanumeric and -, and _, and +
    s = s.escape # URL friendly
    s
  end
end
