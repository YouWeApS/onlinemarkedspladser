# frozen_string_literal: true

class AlphaNumSku < Sku
  def to_s
    sku.to_s.gsub(/[\W]+/, '')
  end
end
