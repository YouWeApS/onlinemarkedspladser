# frozen_string_literal: true

class String
  def number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end

  def escape
    CGI.escape to_s
  end

  def to_boolean
    ActiveRecord::Type::Boolean.new.cast(self)
  end
end
