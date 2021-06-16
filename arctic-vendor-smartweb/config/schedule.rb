env :PATH, ENV['PATH']
set :output, error: 'log/cron-error.log', standard: 'log/cron-standard.log'
set :environment_variable, 'RACK_ENV'

every '*/15 * * * *' do
  rake 'sync:v1:products:collect'
end

every '*/10 * * * *' do
  rake 'sync:v1:orders:disperse'
end

every '35 * * * *' do
  rake 'sync:v1:orders:collect'
end

# every '0 1 * * 7' do
#   rake 'sync:v1:categories:collect'
# end
