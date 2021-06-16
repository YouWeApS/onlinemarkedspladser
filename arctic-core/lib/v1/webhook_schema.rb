# frozen_string_literal: true

class V1::WebhookSchema
  ITEM = {
    type: :string,
    format: :url,
    attrs: {
      autoComplete: :on,
      placeholder: 'https://webshop.com/hooks',
    },
  }.freeze

  SCHEMA = {
    type: :object,

    properties: {
      product_created: ITEM.merge(title: 'Product created by vendor'),
      product_updated: ITEM.merge(title: 'Product updated by vendor'),
      shadow_product_updated: ITEM.merge(title: 'Product updated user'),
    },
  }.freeze
end
