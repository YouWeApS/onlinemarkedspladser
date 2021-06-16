# frozen_string_literal: true

class ApiController < ActionController::API
  def append_info_to_payload(payload)
    super

    append_request_id payload
    append_params payload
    append_authorization_header payload

    payload
  end

  private

    def append_request_id(payload)
      payload[:request_id] = request.request_id
    end

    def append_params(payload)
      payload[:params] = params.permit!.to_h
    end

    def append_authorization_header(payload)
      payload[:headers] ||= {}

      payload[:headers][:Authorization] ||=
        request.headers.to_h.deep_symbolize_keys.fetch(:HTTP_AUTHORIZATION, 'no token')
    end
end
