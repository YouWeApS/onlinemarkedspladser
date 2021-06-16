require "spec_helper"

RSpec.describe "whenever" do
  let(:whenever) { `bundle exec whenever` }

  describe 'line1' do
    subject { whenever.split("\n")[0] }

    let(:time) do
      "01,31 * * * *"
    end

    let(:cmd) do
      "bundle exec rake sync:products"
    end

    it { is_expected.to include time }

    it { is_expected.to include cmd }
  end

  describe 'line2' do
    subject { whenever.split("\n")[2] }

    let(:time) do
      "*/10 * * * *"
    end

    let(:cmd) do
      "bundle exec rake sync:inventory"
    end

    it { is_expected.to include time }

    it { is_expected.to include cmd }
  end

  describe 'line3' do
    subject { whenever.split("\n")[4] }

    let(:time) do
      "*/10 * * * *"
    end

    let(:cmd) do
      "bundle exec rake sync:orders"
    end

    it { is_expected.to include time }

    it { is_expected.to include cmd }
  end
end
