# frozen_string_literal: true

class Amazon::Workers::ProductError < Amazon::Workers::Base
  # rubocop:disable Style/RescueStandardError

  def perform(shop_id, sku, error)
    core_api.report_error shop_id, sku, error
    core_api.update_product_state shop_id, sku, :failed if error[:severity] == 'error'
  rescue => e
    Arctic.logger.error "#{log_msg} (#{e.class}): #{e.message}: #{error}"
  end

  # rubocop:enable Style/RescueStandardError

  private

    def log_msg
      'Unable to report error to Core API'
    end
end
