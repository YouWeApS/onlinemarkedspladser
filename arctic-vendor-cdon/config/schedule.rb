# frozen_string_literal: true

# Don't run the rake task silently
# http://bit.ly/2Oqepnv
job_type :rake, "cd :path && :environment_variable=:environment /home/vendor/.rbenv/shims/bundle exec rake :task :output"

# Set the logs for the cron jobs
# http://bit.ly/2vfymoh
set :output, {
  error: '/home/vendor/apps/vendor/shared/log/cron.error.log',
  standard: '/home/vendor/apps/vendor/shared/log/cron.log',
}

every 1.hour do
  rake 'sync:v1:products:all'
end

every 10.minutes do
  rake 'sync:v1:orders:all'
end
