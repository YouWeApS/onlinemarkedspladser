# frozen_string_literal: true

class Numeric
  def percent_of(number)
    to_f / 100.0 * number
  end
end

class Float
  def percent_of(number)
    to_f / 100.0 * number
  end
end
