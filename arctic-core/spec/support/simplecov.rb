require 'simplecov'

SimpleCov.start 'rails' do
  add_group "Blueprints", "app/blueprints"
  add_filter "lib/eu_central_bank_wrapper.rb"
end

# Overall, minimum coverage
SimpleCov.minimum_coverage 90

# Per-file minimum coverage
SimpleCov.minimum_coverage_by_file 80

# Don't allow test coverage drop
SimpleCov.maximum_coverage_drop 0.5

# Allow SimpleCov to work alongside spring
# http://bit.ly/2z7m1EF
Rails.application.eager_load!
