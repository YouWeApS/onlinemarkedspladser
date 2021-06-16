# frozen_string_literal: true

namespace :systemd do
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute 'sudo systemctl start mirakl-web'
        execute 'sudo systemctl start sidekiq'
      end
    end
  end

  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute 'sudo systemctl stop mirakl-web'
        execute 'sudo systemctl stop sidekiq'
      end
    end
  end

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute 'sudo systemctl restart mirakl-web'
        execute 'sudo systemctl restart sidekiq'
      end
    end
  end
end
