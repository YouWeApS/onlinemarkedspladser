# frozen_string_literal: true

if Rails.env.production?
  namespace :db do
    namespace :seed do
      desc 'Dump production db'
      task dump_prod: :environment do
        system 'rake db:seed:dump FILE=db/seeds/production.all'
      end
    end
  end
end
