require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :new_episodes }
end

RSpec.configure do |config|
  config.around(:each) do |e|
    vcr = e.metadata[:vcr]
    name = vcr
    options = {}

    if vcr.is_a? Hash
      name = vcr[:name]
      options = vcr.except(:name)
    end

    options.reverse_merge! \
      record: :none

    if vcr.present?
      VCR.use_cassette(name, options) do
        e.run
      end
    else
      e.run
    end
  end
end
