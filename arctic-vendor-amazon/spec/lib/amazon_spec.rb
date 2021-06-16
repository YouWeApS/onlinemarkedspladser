require "spec_helper"

RSpec.describe Amazon do
  it 'sets the right $LOAD_PATH' do
    load_path = File.expand_path('../../lib', __dir__)
    expect($LOAD_PATH).to include load_path
  end

  it 'loads the .env file' do
    expect(ENV.fetch('LOG_LEVEL')).to eql 'info'
  end

  it 'sets the Arctic.validator_class' do
    expect(Arctic.validator_class).to eql Amazon::Validator
  end
end
