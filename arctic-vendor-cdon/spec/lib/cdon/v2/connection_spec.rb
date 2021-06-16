require 'spec_helper'

RSpec.describe CDON::V2::Connection do
  let(:instance) { described_class.new api_key }
  let(:api_key) { 'dummy-key-1' }

  subject { instance }
end
