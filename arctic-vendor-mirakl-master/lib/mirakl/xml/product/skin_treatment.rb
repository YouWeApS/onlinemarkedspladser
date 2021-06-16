# frozen_string_literal: true

class Mirakl::XML::Product::SkinTreatment < Mirakl::XML::Product::Builder
  def build_xml
    super

    build_depth
    build_overheat
    build_cordless
    build_massage_sets
    build_washable
    build_weight
    build_display
    build_watt
    build_electronic
  end

  private

  def build_depth
    attribute_builder(CODE_DEPTH, depth)
  end

  def build_overheat
    attribute_builder(CODE_OVERHEAT, true_false(overheat))
  end

  def build_cordless
    attribute_builder(CODE_CORDLESS, true_false(cordless))
  end

  def build_massage_sets
    attribute_builder(CODE_MASSAGE_SETS, massage_sets)
  end

  def build_washable
    attribute_builder(CODE_WASHABLE, true_false(washable))
  end

  def build_weight
    attribute_builder(CODE_WEIGHT, weight)
  end

  def build_display
    attribute_builder(CODE_DISPLAY, true_false(display))
  end

  def build_watt
    attribute_builder(CODE_WATT, watt)
  end

  def build_electronic
    attribute_builder(CODE_ELECTRONIC, true_false(electronic))
  end
end