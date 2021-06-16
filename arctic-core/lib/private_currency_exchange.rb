# frozen_string_literal: true

# This is a private currency exchange used when shops have currency conversions
# available.
#
# See https://github.com/RubyMoney/money#exchange-rate-stores
#
class PrivateCurrencyExchange
  attr_reader :exchange_rates

  def initialize(shop)
    @exchange_rates = shop.currency_conversions
  end

  def get_rate(from_currency, to_currency)
    rate = exchange_rates.find_by \
      from_currency: from_currency,
      to_currency: to_currency
    rate.try :rate
  end

  def add_rate(*)
    raise \
      NotImplementedError,
      'Use the currencies endpoint to add/update exchange rates'
  end
end
