# frozen_string_literal: true

module Mirakl::Helpers::ProductDataHelper
  def sku
    @sku ||= product['sku']
  end

  def title
    @title ||= product['name']
  end

  def ean
    @ean ||= product['ean']
  end

  def category
    @category = product.dig('categories', 0, 'mirakl_vendor_category')
  end

  def brand
    @brand ||= product['brand']
  end

  def short_description
    @short_description ||= product['description']
  end

  def images
    @images ||= product.fetch('images', [])
  end

  def depth
    @depth ||= product['depth']
  end

  def overheat
    @overheat ||= product['overheat']
  end

  def cordless
    @cordless ||= product['cordless']
  end

  def massage_sets
    @massage_sets ||= product['massage_sets']
  end

  def washable
    @washable ||= product['washable']
  end

  def weight
    @weight ||= product['weight']
  end

  def display
    @display ||= product['display']
  end

  def watt
    @watt ||= product['watt']
  end

  def electronic
    @electronic ||= product['electronic']
  end

  def quantity
    @quantity ||= product['stock_count']
  end

  def price
    @price ||= product['original_price']
  end

  def discount_price
    @discount_price ||= product['offer_price']
  end
end