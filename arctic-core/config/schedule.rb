# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

bundle_path = '/usr/local/rbenv/shims/bundle'

# Don't run the rake task silently
# http://bit.ly/2Oqepnv
job_type :rake, <<-STR
  cd :path && :environment_variable=:environment #{bundle_path} exec rake :task :output
STR

every '50 * * * *' do
  rake 'products:cleanup'
end

every 1.hour do
  rake 'vendor_locks:cleanup'
end
