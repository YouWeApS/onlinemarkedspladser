# frozen_string_literal: true

# rubocop:disable Lint/ShadowingOuterLocalVariable

class Amazon::XML::ProductData::Beauty < Amazon::XML::ProductData::Base
  def validator_schema_name
    'Beauty'
  end

  def build_xml
    xml_builder.Beauty do |xml|
      xml.ProductType do |xml|
        xml.Fragrance do |xml|
          build_variation_data xml
          build_count xml
          build_gender xml
          build_sizemap xml
        end
      end
    end
  end

  private

    def scent
      @scent ||= product.fetch('scent', nil).to_s.strip
    end

    def count
      @count ||= product.fetch('count', nil).to_s.strip
    end

    def gender
      @gender ||= product.fetch('gender', nil).to_s.strip
    end

    def build_variation_data(xml)
      xml.VariationData do |xml|
        build_parentage xml
        build_variation_theme xml
        build_size xml
        build_color xml
        build_scent xml
      end
    end

    def build_parentage(xml)
      xml.Parentage parentage
    end

    def build_variation_theme(xml)
      xml.VariationTheme variation_theme
    end

    def build_size(xml)
      xml.Size size if size.present?
    end

    def build_color(xml)
      xml.Color color if color.present?
      xml.ColorMap color if color.present? && master?
    end

    def build_scent(xml)
      xml.Scent scent if scent.present?
    end

    def build_count(xml)
      xml.Count count if count.present?
    end

    def build_gender(xml)
      xml.TargetGender gender if gender.present?
    end

    def build_sizemap(xml)
      xml.SizeMap size if size.present? && master?
    end
end

# rubocop:enable Lint/ShadowingOuterLocalVariable
