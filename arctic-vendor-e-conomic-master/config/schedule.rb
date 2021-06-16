set :output, error: 'log/cron-error.log', standard: 'log/cron-standard.log'
set :environment_variable, 'RACK_ENV'

every '*/10 * * * *' do
  rake 'sync:v1:orders:disperse'
end
