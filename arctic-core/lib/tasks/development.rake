# frozen_string_literal: true

# rubocop:disable Lint/HandleExceptions

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
  end
rescue LoadError
  # noop
end

namespace :dev do
  desc 'Start development server'
  task start: :environment do
    system 'bundle exec foreman start -f Procfile.dev'
  end

  desc '(Re)generate documentation'
  task documentation: :environment do
    system 'bundle exec rspec --format Rswag::Specs::SwaggerFormatter'
  end
end

task default: %i[spec rubocop dev:documentation]

# rubocop:enable Lint/HandleExceptions
