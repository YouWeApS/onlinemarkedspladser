# config valid for current version and patch releases of Capistrano
lock "~> 3.12.1"

set :repo_url,        ''
set :application,     'arctic-vendor-e-conomic'
set :user,            'vendor'
set :log_level,       :debug

set :rvm_custom_path, '/usr/share/rvm'

set :branch,          `git rev-parse --abbrev-ref HEAD`.chomp
set :pty,             false
set :stage,           :production
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Symlin .env from shared files
set :linked_files, %w{.env}

append :linked_dirs, 'log'

set :whenever_roles, :app

namespace :deploy do
  after :finishing, 'systemd:restart'
end
