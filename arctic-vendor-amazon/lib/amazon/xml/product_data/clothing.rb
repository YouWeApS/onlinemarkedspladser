# frozen_string_literal: true

class Amazon::XML::ProductData::Clothing < Amazon::XML::ProductData::Base
  def validator_schema_name
    'ProductClothing'
  end

  def build_xml
    # rubocop:disable Lint/ShadowingOuterLocalVariable

    xml_builder.Clothing do |xml|
      xml.VariationData do |xml|
        xml.Parentage parentage
        bulid_child_variation_theme xml if variation_theme && child?
        xml.VariationTheme variation_theme if variation_theme
      end

      build_classification_data xml
    end

    # rubocop:enable Lint/ShadowingOuterLocalVariable
  end

  private

    def size
      case super.upcase
      when 'S' then 'Small'
      when 'M' then 'Medium'
      when 'L' then 'Large'
      when 'XL' then 'X-Large'
      when 'XXL' then 'XX-Large'
      when 'XXXL' then 'XXX-Large'
      else super.capitalize
      end
    end

    def bulid_child_variation_theme(xml)
      case variation_theme
      when 'Size-Material'
        xml.Size size
      when 'SizeColor'
        xml.Size size
        xml.Color color
      when 'Size'
        xml.Size size
      when 'Color'
        xml.Color color
      end
    end

    def build_classification_data(xml)
      # NOTE: Information already present in the VariationTheme block
      #       shouldn't be repeated in the ClassificationData block.
      xml.ClassificationData do
        build_classification_size xml
        build_classification_color xml
        build_clothing_type xml
        build_color_map xml

        # NOTE: Contrary to the comment about the non-duplicates in
        #       VariationTheme/ClassificationData blocks, MaterialType
        #       should NOT go into the VariationTheme block like size
        #       and color does.
        xml.MaterialComposition material if material.present?
        build_size_map xml
      end
    end

    def build_classification_size(xml)
      return if variation_theme.include? 'Size'

      xml.Size size if size.present? && child?
    end

    def build_classification_color(xml)
      return if variation_theme.include? 'Color'

      xml.Color color if color.present? && child?
    end

    def build_clothing_type(xml)
      xml.ClothingType category.fetch('classification') if category.fetch('classification', false)
    end

    def build_color_map(xml)
      xml.ColorMap color if color.present?
    end

    def build_size_map(xml)
      xml.SizeMap size if size.present?
    end
end
