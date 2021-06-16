require 'rails_helper'

RSpec.describe 'Sidekiq setup' do
  it 'has the correct sidekiq.yml file' do
    expected_content = <<~YAML.strip_heredoc
      :concurrency: 3
      production:
        :concurrency: 10
      :queues:
        - [product_caches, 10]
        - [product_matches, 10]
        - [shadow_products, 5]
        - webhooks
        - product_exports
        - product_imports
    YAML

    content = File.read Rails.root.join('config', 'sidekiq.yml')

    expect(content).to eql expected_content
  end
end
