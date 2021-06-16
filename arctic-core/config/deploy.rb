# frozen_string_literal: true

require 'dotenv'
Dotenv.load

namespace :deploy do
  desc 'Mock deploy:compile_assets'
  task :compile_assets do
  end
end

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :repo_url,        '#'
set :application,     'core_api'
set :user,            fetch(:application)
set :log_level,       :debug

set :rbenv_type, :user
set :rbenv_ruby, '2.5.1'

set :branch,          `git rev-parse --abbrev-ref HEAD`.chomp
set :pty,             false
set :stage,           :production
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Symlin .env from shared files
set :linked_files, %w[.env config/credentials.yml.enc config/master.key]

append :linked_dirs,
  'tmp/pids',
  'tmp/sockets',
  'log'

# Rollbar deploy reporting
# http://bit.ly/2NYUKtR
set :rollbar_token, ENV['ROLLBAR_TOKEN']
set :rollbar_env, (proc { fetch :stage })
set :rollbar_role, :app
set :rollbar_comment, `git log -1 --pretty=%B`.chomp # Last git comment

set :whenever_roles, :app

# https://github.com/seuros/capistrano-newrelic#in-stage-files
before 'deploy:finished', 'newrelic:notice_deployment'

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

after 'deploy:published', 'sidekiq:restart'
