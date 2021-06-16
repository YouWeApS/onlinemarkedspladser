class AddSpecificFieldsToShadowProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :shadow_products, :key_features, :json, default: {}
    add_column :shadow_products, :platinum_keywords, :json, default: {}
    add_column :shadow_products, :legal_disclaimer, :text
    add_column :shadow_products, :search_terms, :text
  end
end
