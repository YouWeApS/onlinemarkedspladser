desc 'Start developer application'
task :start do
  system 'bundle exec foreman start -f Procfile.dev'
end
