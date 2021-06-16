# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, perform_sidekiq: true) do |e|
    Sidekiq::Testing.inline!
    e.run
    Sidekiq::Testing.fake!
  end
end
