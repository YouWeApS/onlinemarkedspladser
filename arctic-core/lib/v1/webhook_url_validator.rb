# frozen_string_literal: true

class V1::WebhookUrlValidator
  Error = Class.new StandardError
  NotConfigured = Class.new Error
  MissConfigured = Class.new Error

  def self.validate(endpoint, url)
    uri = URI url.to_s

    raise NotConfigured, "no webhook configured for #{endpoint}" if url.blank?

    http = uri.class.to_s.include? 'URI::HTTP'
    raise MissConfigured, "invalid webhook configured for #{endpoint}" unless http

    https = uri.class.to_s.include? 'URI::HTTPS'
    raise MissConfigured, "webhook for #{endpoint} must be an HTTPS url" unless https
  end
end
