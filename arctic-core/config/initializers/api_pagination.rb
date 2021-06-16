# frozen_string_literal: true

ApiPagination.configure do |config|
  # Return current page number as a response header
  config.page_header = 'Page'
end
