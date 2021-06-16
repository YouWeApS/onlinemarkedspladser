# frozen_string_literal: true

class Smartweb::V1::Formatters::FormatCategory
  attr_reader :category

  def initialize(category)
    @category = category
  end

  def format
    Arctic.logger.info "Formatting category #{category['id']}"

    {
      original_id: category.fetch(:id),
      name: category.fetch(:title)
    }
  rescue => e
    Rollbar.error e, 'Failed to format Category', category: category
    raise e
  end
end
