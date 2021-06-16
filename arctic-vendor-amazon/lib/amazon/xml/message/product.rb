# frozen_string_literal: true

# rubocop:disable Lint/ShadowingOuterLocalVariable

class Amazon::XML::Message::Product < Amazon::XML::Message::Base
  private

    def build_sku(xml)
      xml.SKU product.fetch 'sku'
      # Must be used in future like this.
      # It will make possible to change SKU before send to Amazon.
      # xml.SKU mapped_value 'sku'
    end

    def build_standard_product_id(xml)
      standard_product_id xml if ean.present?
    end

    def standard_product_id(xml)
      xml.StandardProductID do |xml|
        xml.Type 'EAN'
        xml.Value product.fetch('ean')
      end
    end

    def build_product_tax_code(xml)
      xml.ProductTaxCode product.fetch('tax_code', 'A_GEN_NOTAX')
    end

    def build_condition(xml)
      xml.Condition do |xml|
        xml.ConditionType product.fetch('condition', 'New')
      end
    end

    def build_title(xml)
      xml.Title product.fetch('name')
    end

    def build_brand(xml)
      xml.Brand brand if brand.present?
    end

    def build_description(xml)
      xml.Description description if description.present?
    end

    def build_bullet(xml)
      key_features.each do |bullet|
        xml.BulletPoint bullet[1]
      end
    end

    def build_legal_disclaimer(xml)
      xml.LegalDisclaimer legal_disclaimer if legal_disclaimer.present?
    end

    def build_manufacturer(xml)
      xml.Manufacturer manufacturer if manufacturer.present?
    end

    def build_search_terms(xml)
      xml.SearchTerms search_terms if search_terms.present?
    end

    def build_platinum_keywords(xml)
      platinum_keywords.each do |keyword|
        xml.PlatinumKeywords keyword[1]
      end
    end

    def build_browser_node(xml)
      xml.RecommendedBrowseNode browser_node if browser_node.present?
    end

    def build_product_data(xml)
      xml.ProductData do |xml|
        Amazon::XML::ProductData.new(xml, product, **options).build_xml
      end
    end

    def message_array
      %w(sku standard_product_id product_tax_code condition description_data product_data)
    end

    def description_array
      %w(title brand description bullet legal_disclaimer manufacturer search_terms platinum_keywords browser_node)
    end

    def build_message_content(xml)
      xml.Product do |xml|
        message_array.each do |method|
          send('build_' + method, xml)
        end
      end
    end

    def build_description_data(xml)
      xml.DescriptionData do |xml|
        description_array.each do |method|
          send('build_' + method, xml)
        end
      end
    end
end

# rubocop:enable Lint/ShadowingOuterLocalVariable
