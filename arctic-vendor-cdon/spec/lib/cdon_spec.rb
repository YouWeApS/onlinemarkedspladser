require 'spec_helper'

RSpec.describe CDON do
  it 'adds lib to load path' do
    expect($LOAD_PATH).to include File.expand_path('..', __dir__)
  end
end
