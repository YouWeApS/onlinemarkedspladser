# frozen_string_literal: true

# rubocop:disable Style/RescueStandardError

require 'eu_central_bank_wrapper'

Money.default_bank = EuCentralBankWrapper.instance

begin
  EuCentralBankWrapper.update_rates
rescue => e
  Rails.logger.warn "Unable to fetch exchange rates from EU central bank (#{e.class}): #{e.message}"
end

# rubocop:enable Style/RescueStandardError
