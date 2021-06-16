# frozen_string_literal: true

class Mirakl::Api
  IMPORTS_URL     = '/api/products/imports'
  VALUES_LIST_URL = '/api/values_lists'
  ORDERS_URL      = '/api/orders'

  attr_reader :shop

  def initialize(shop)
    @shop = shop
  end

  def create_import(filename)
    JSON.parse(send_to_mirakl(:post, imports_base_url, payload: { file: File.new(filename, 'rb') }).body)
  end

  def get_import(import_id)
    url = imports_base_url + '/' + import_id.to_s

    JSON.parse(send_to_mirakl(:get, url))
  end

  def get_error_report(import_id)
    url = imports_base_url + '/' + import_id.to_s + '/transformation_error_report'

    response = send_to_mirakl(:get, url)

    Mirakl::Services::Archive.archive_xml(response, shop['id'], :response)

    Hash.from_xml(response)
  end

  def get_brand_code(brand)
    url = config['host'] + VALUES_LIST_URL

    response = JSON.parse(send_to_mirakl(:get, url))

    api_brand = response['values_lists'].find { |item| item['code'] == 'Brand' }['values'].find do |value|
      value['label'] == brand
    end

    return unless api_brand.present?

    api_brand['code']
  end

  def get_orders(state:, since: nil)
    url = config['host'] + ORDERS_URL

    params = {
      order_state_codes: state,
      start_update_date: since,
      paginate: false
    }

    JSON.parse(send_to_mirakl(:get, url, params: params))
  end

  def get_order order_id
    url = config['host'] + ORDERS_URL

    JSON.parse(send_to_mirakl(:get, url, params: { order_ids: order_id })).first
  end

  def accept_order(order_id, order_data)
    url = config['host'] + ORDERS_URL + "/#{order_id}/accept"

    send_to_mirakl(:put, url, payload: order_data)
  end

  def ship_order(order_id)
    url = config['host'] + ORDERS_URL + "/#{order_id}/ship"

    send_to_mirakl(:put, url)
  end

  def update_order_tracking(order_id, order_data)
    url = config['host'] + ORDERS_URL + "/#{order_id}/tracking"

    send_to_mirakl(:put, url, payload: order_data)
  end

  private

  def imports_base_url
    @import_url ||= config['host'] + IMPORTS_URL
  end

  def config
    @config ||= shop['config']
  end

  def auth_config
    @auth_config ||= shop['auth_config']
  end

  def send_to_mirakl(http_method, url, params: {}, payload: {})
    RestClient::Request.new(
      url:     url,
      method:  http_method,
      headers: { authorization: auth_config['api_key'] },
      params:  params,
      payload: payload
    ).execute
  end
end