# Don't run the rake task silently
# http://bit.ly/2Oqepnv
job_type :rake, "cd :path && :environment_variable=:environment /home/vendor/.rbenv/shims/bundle exec rake :task :output"

# Set the logs for the cron jobs
# http://bit.ly/2vfymoh
set :output, {
  error: '/home/vendor/apps/vendor/shared/log/cron.error.log',
  standard: '/home/vendor/apps/vendor/shared/log/cron.log',
}

# Run on minute 40 every hour
every '40 * * * *' do
  rake "sync:all"
end

# Run orders sync every 10 minutes
every '*/10 * * * *' do
  rake "sync:v2:orders:all"
end
