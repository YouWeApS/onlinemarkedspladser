# frozen_string_literal: true

class V1::ApplicationController < ApiController #:nodoc:
  include HttpError::Response

  after_action :log_response_json_to_file

  rescue_from ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid do |e|
    logger.error "Translating #{e.class} -> HttpError::BadRequest: #{e.message}"
    logger.debug e.backtrace.join("\n")
    error = HttpError::BadRequest.new e.message
    render_error error
  end

  rescue_from ActionController::ParameterMissing,
    Pagy::OutOfRangeError,
    ActiveRecord::ValueTooLong do |e|
    logger.error "Translating #{e.class} -> HttpError::BadRequest: #{e.message}"
    logger.debug e.backtrace.join("\n")
    error = HttpError::BadRequest.new e.message
    render_error error
  end

  rescue_from PG::ExternalRoutineInvocationException do |e|
    logger.error "Translating #{e.class} -> HttpError::InternalServerError: #{e.message}"
    logger.debug e.backtrace.join("\n")
    error = HttpError::InternalServerError.new 'Internal server error. Please try again later'
    render_error error
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    logger.error "Translating #{e.class} -> HttpError::NotFound: #{e.message}"
    logger.debug e.backtrace.join("\n")
    error = HttpError::NotFound.new e.message
    render_error error
  end

  rescue_from ActiveRecord::RecordNotUnique do |e|
    logger.error "Translating #{e.class} -> HttpError::NotFound: #{e.message}"
    logger.debug e.backtrace.join("\n")
    error = HttpError::InternalServerError.new 'Internal server error. Please try again later'
    render_error error
  end

  def log_response_json_to_file
    return unless ENV.fetch('LOG_RESPONSES', false)

    return unless format_response_json

    File.open(log_response_file, 'w') { |f| f.write format_response_json }
  end

  def format_response_json
    JSON.pretty_generate JSON.parse response.body
  rescue JSON::ParserError
    nil
  end

  def log_response_file
    date = Time.zone.now.to_s(:db)
    filename = "#{date}-#{request.headers['action_dispatch.request_id']}.json"
    Rails.root.join('log', 'responses', filename).tap do |path|
      FileUtils.mkdir_p File.dirname path
    end
  end
end
