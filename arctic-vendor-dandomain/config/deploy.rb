require 'dotenv'
Dotenv.load

# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

server '',
  roles: %i(app),
  primary: true

set :repo_url,        ''
set :application,     'vendor'
set :user,            'vendor'
set :log_level,       :debug

set :rbenv_type, :user
set :rbenv_ruby, '2.5.1'

set :branch,          `git rev-parse --abbrev-ref HEAD`.chomp
set :pty,             false
set :stage,           :production
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Symlin .env from shared files
set :linked_files, %w{.env}

append :linked_dirs, 'log'

set :whenever_roles, :app

set :datadog_api_key, ENV.fetch('26a4bd84c6b26d2d53f878f0b348598f', :missing_dd_api_key)
