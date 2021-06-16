# frozen_string_literal: true

require 'dotenv'
Dotenv.load

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :repo_url, ''
set :application, 'vendor'
set :user, 'vendor'
set :log_level, :debug

set :rbenv_type, :user
set :rbenv_ruby, '2.5.1'

set :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :stage, :production
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Symlin .env from shared files
set :linked_files, %w[.env config.ru]

# Symlink dirs from shared
append :linked_dirs,
  'log',
  'archive',
  'tmp'

set :whenever_roles, :app

set :validation_api_pid, -> { "#{current_path}/tmp/pids/validation_api.pid" }

namespace :service do
  desc 'Restart named service'
  task :restart, %i[name] do |_, args|
    on roles(:app) do
      within current_path.to_s do
        execute "echo '' | sudo systemctl restart #{args['name']}.service"
      end
    end
  end
end

namespace :sidekiq do
  desc 'Restart sidekiq service'
  task :restart do
    Rake::Task['service:restart'].invoke :sidekiq
  end
end

namespace :validation_api do
  desc 'Restart sidekiq service'
  task :restart do
    Rake::Task['service:restart'].invoke 'validation-api'
  end
end

after 'deploy:published', 'sidekiq:restart'
after 'deploy:published', 'validation_api:restart'
