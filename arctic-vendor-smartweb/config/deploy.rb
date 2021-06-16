require 'dotenv'
Dotenv.load

# config valid for current version and patch releases of Capistrano
lock "~> 3.12.0"

set :repo_url,        ''
set :application,     'vendor'
set :user,            'vendor'
set :log_level,       :debug

set :rvm_custom_path, '/usr/share/rvm'

# set :rbenv_type, :user
# set :rbenv_ruby, '2.7.0'

# set :branch,          `git rev-parse --abbrev-ref HEAD`.chomp
set :branch,          'master'
# ask :branch,          proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :keep_releases,   3
set :format,          :pretty
set :pty,             false
set :stage,           :production
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Symlin .env from shared files
set :linked_files, %w{.env}

append :linked_dirs, 'log'

# Rollbar deploy reporting
# http://bit.ly/2NYUKtR
set :rollbar_token, ENV['ROLLBAR_ACCESS_TOKEN']
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, :app

set :whenever_roles, :app

namespace :deploy do
  after :finishing, 'systemd:restart'
end
