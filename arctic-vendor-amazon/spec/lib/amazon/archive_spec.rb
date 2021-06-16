require "spec_helper"

RSpec.describe Amazon::Archive do
  let(:instance) { described_class.new name, content, **options }
  let(:options) { { subdir: :b } }
  let(:name) { 'file-a' }
  let(:content) do
    <<~XML.strip_heredoc
      <a>Something</a>
    XML
  end

  let(:expected_path) { File.expand_path "../../../archive/b/file-a.xml", __dir__ }

  subject { instance }

  its(:name) { is_expected.to eql 'file-a' }
  its(:content) { is_expected.to eql content }
  its(:options) { is_expected.to eql 'subdir' => :b }
  its(:path) { is_expected.to eql expected_path }

  describe '#save' do
    subject { instance.save }
    after { FileUtils.rm expected_path }
    before(:each) { FileUtils.rm expected_path if File.exist? expected_path }

    it { expect { subject }.to change { File.exists? expected_path }.from(false).to(true) }
  end
end
