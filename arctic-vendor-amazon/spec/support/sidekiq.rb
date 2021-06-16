require 'rspec-sidekiq'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

# https://github.com/philostler/rspec-sidekiq#configuration
RSpec::Sidekiq.configure do |config|
end
