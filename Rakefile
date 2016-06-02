require 'rspec/core/rake_task'

namespace :db do
  desc "create the database"
  task :create, [:username] do |_, args|
    sh "psql -c 'create database authy2fa_sinatra_test;'"
    sh "psql -c 'create database authy2fa_sinatra;'"
  end
end

RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['spec/**/*_spec.rb']
  task.verbose = false
end

task :default => ['specs']
