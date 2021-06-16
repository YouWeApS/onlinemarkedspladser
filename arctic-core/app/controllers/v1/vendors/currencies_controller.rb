# frozen_string_literal: true

class V1::Vendors::CurrenciesController < V1::Vendors::ApplicationController #:nodoc:
  def index
    render json: conversion_blueprints
  end

  def update
    currency_conversion.rate = params.fetch(:rate)
    currency_conversion.save!
    render json: V1::Vendors::CurrencyConversionBlueprint.render(currency_conversion)
  end

  private

    def shop
      current_vendor.collection_shops.find params[:shop_id]
    end

    def conversion_blueprints
      shop.currency_conversions.collect do |conv|
        V1::Vendors::CurrencyConversionBlueprint.render_as_hash(conv)
      end
    end

    def currency_conversion
      @currency_conversion ||= shop
        .currency_conversions
        .find_or_initialize_by \
          from_currency: params.fetch(:from_currency).to_s.upcase,
          to_currency: params.fetch(:to_currency).to_s.upcase
    end
end
