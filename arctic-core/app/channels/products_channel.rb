# frozen_string_literal: true

class ProductsChannel < ApplicationCable::Channel #:nodoc:
  def subscribed
    logger.info "User(#{current_user.email}) subscribed"
    stream_from "products:#{current_user.id}"
  end
end
