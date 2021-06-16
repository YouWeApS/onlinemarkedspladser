desc 'Start SmartwebVendor application'
task :start do
  system 'bundle exec foreman start -f Procfile.dev'
end
