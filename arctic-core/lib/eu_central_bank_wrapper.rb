# frozen_string_literal: true

require 'eu_central_bank'

class EuCentralBankWrapper
  class << self
    def instance
      @instance ||= EuCentralBank.new
    end

    def update_rates
      instance.update_rates
    end
  end
end
