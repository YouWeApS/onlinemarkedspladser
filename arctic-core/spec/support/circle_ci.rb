RSpec.configure do |config|
  # https://stackoverflow.com/a/26474044/1146473
  config.before(:example, :focus) do
    fail 'This example was committed with `:focus` and should not have been'
  end if ENV.fetch('CI', false)
end
