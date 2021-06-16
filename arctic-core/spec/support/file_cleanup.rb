RSpec.configure do |config|
  config.before(:suite) do
    dir = Rails.root.join('tmp', 'exports')
    FileUtils.rm_r dir if Dir.exists? dir

    dir = Rails.root.join('tmp', 'imports')
    FileUtils.rm_r dir if Dir.exists? dir
  end

  config.after(:suite) do
    dir = Rails.root.join('tmp', 'exports')
    FileUtils.rm_r dir if Dir.exists? dir

    dir = Rails.root.join('tmp', 'imports')
    FileUtils.rm_r dir if Dir.exists? dir
  end
end
