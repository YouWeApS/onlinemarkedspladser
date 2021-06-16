# frozen_string_literal: true

Rswag::Ui.configure do |c|
  c.swagger_endpoint '/swagger/v1/vendors/swagger.json', 'Vendor API V1'
  c.swagger_endpoint '/swagger/v1/ui/swagger.json', 'UI API V1'
end
