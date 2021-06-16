set :output, error: 'log/cron-error.log', standard: 'log/cron-standard.log'
set :environment_variable, 'RACK_ENV'

every '30 * * * *' do
  rake 'sync:products:collect'
end

every '*/5 * * * *' do
  rake 'sync:orders:collect'
end

every '*/10 * * * *' do
  rake 'sync:orders:vendor_update'
end
