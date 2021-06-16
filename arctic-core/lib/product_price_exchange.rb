# frozen_string_literal: true

class ProductPriceExchange
  MissingPrice = Class.new StandardError

  attr_accessor \
    :bank,
    :config,
    :exchange_to_currency,
    :money,
    :shop,
    :vendor

  def initialize(product_price, options)
    raise ProductPriceExchange::MissingPrice, 'missing product_price' unless product_price

    @shop = options[:shop]
    @vendor = options[:vendor]
    @money = product_price.price
    @exchange_to_currency = money.currency.to_s

    calculate_money_and_bank

    calculate_config_and_exchange
  end

  def price
    adjust_price exchange
  end

  private

    def calculate_config_and_exchange
      return if !shop || !vendor

      @config = shop.vendor_config_for vendor
      @exchange_to_currency = config.currency_config['currency'] if config.currency_config['currency']
    end

    def calculate_money_and_bank
      return unless shop

      @bank = Money::Bank::VariableExchange.new PrivateCurrencyExchange.new(shop)
      @money = Money.new money.cents, money.currency.to_s, bank
    end

    def exchange
      money.exchange_to exchange_to_currency
    rescue Money::Bank::UnknownRate => e
      Rails.logger.debug "#{e.message}: Using default bank exchange rate."
      EuCentralBankWrapper.instance.exchange_with money, exchange_to_currency.to_s.upcase
    end

    def adjust_price(value)
      case config.try(:price_adjustment_type)
      when 'percent' then adjust_price_by_percent(value)
      else value
      end
    end

    def adjust_price_by_percent(value)
      cents = [
        value.cents,
        config.price_adjustment_value.percent_of(value.cents),
      ].sum
      Money.new cents, value.currency
    end
end
