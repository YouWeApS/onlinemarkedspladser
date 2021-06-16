# frozen_string_literal: true

class V1::Ui::UtilsController < V1::Ui::ApplicationController
  def currencies
    doorkeeper_authorize!

    http_cache_forever public: true do
      render json: V1::Ui::CurrencyBlueprint.render(Money::Currency.as_json)
    end
  end

  def shipping_carriers
    doorkeeper_authorize!

    http_cache_forever public: true do
      render json: V1::Ui::ShippingCarrierBlueprint.render(ShippingCarrier.all)
    end
  end

  def shipping_methods
    doorkeeper_authorize!

    http_cache_forever public: true do
      render json: V1::Ui::ShippingMethodBlueprint.render(ShippingMethod.all)
    end
  end
end
