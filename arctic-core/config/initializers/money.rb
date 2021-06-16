# frozen_string_literal: true

MoneyRails.configure do |config|
  config.default_currency = :dkk
  config.default_bank = EuCentralBank.new
end
