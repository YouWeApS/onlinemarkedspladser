# frozen_string_literal: true

bundle_path = '/home/vendor/.rbenv/shims/bundle'

# Don't run the rake task silently
# http://bit.ly/2Oqepnv
job_type :rake, <<-STR
  cd :path && :environment_variable=:environment #{bundle_path} exec rake :task :output
STR

# Set the logs for the cron jobs
# http://bit.ly/2vfymoh
set :output,
  error: '/home/vendor/apps/vendor/shared/log/cron.error.log',
  standard: '/home/vendor/apps/vendor/shared/log/cron.log'

# Sync products at minute 01 and 31 of every hour
every '01,31 * * * *' do
  rake 'sync:products'
end

# Sync inventory every 10 minutes
every '*/10 * * * *' do
  rake 'sync:inventory'
end

# Sync orders every 10 minutes
every '*/10 * * * *' do
  rake 'sync:orders'
end
