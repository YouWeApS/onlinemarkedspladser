# frozen_string_literal: true

# Because we're using complex SQL structures that cannot be dumped to schema as
# ruby, and because the rails schema_format isn't working in
# Rails 5 (http://bit.ly/2vM9Xu5) we're simply redirecting the db:schema:load
# and db:schema:dump to the structure counterparts. This will use the
# structure.sql instead of the schema.rb file.
Rake::Task['db:schema:load'].clear
Rake::Task['db:schema:dump'].clear
namespace :db do
  namespace :connections do
    desc 'Kill connections'
    task kill: :environment do
      ActiveRecord::Base.connection.execute <<~SQL
        SELECT pg_terminate_backend( pid )
        FROM pg_stat_activity
        WHERE pid <> pg_backend_pid( )
        AND datname = current_database( );
      SQL
    end
  end
  task drop: %i[db:connections:kill]

  namespace :schema do
    desc 'Redirecting db:schema:load => db:structure:load'
    task load: :environment do
      Rake::Task['db:structure:load'].invoke
    end

    desc 'Redirecting db:schema:load => db:structure:load'
    task dump: :environment do
      Rake::Task['db:structure:dump'].invoke
    end
  end
end
