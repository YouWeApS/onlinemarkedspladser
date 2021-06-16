# frozen_string_literal: true

require 'aws-sdk-s3'

# Store AWS credentials
Aws.config.update \
  region: Rails.application.credentials.dig(:aws, :region) || 'no-region',
  credentials: Aws::Credentials.new(
    Rails.application.credentials.dig(:aws, :access_key_id) || 'no-secret-id',
    Rails.application.credentials.dig(:aws, :secret_access_key) || 'no-secret-key'
  )
