# config valid for current version and patch releases of Capistrano
lock '~> 3.14.1'

set :repo_url,       ''
set :application,    'mirakl'
set :user,           'vendor'
set :deploy_to,      "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :whenever_roles, :app

append :linked_files, '.env'
append :linked_dirs,  '.bundle', 'log', 'archive'

namespace :deploy do
  after :finishing, 'systemd:restart'
end
