require 'rspec/core/rake_task'

db_names = ['authy2fa_sinatra', 'authy2fa_sinatra_test']

namespace :db do
  desc "create the database"
  task :create, [:username] do |_, args|
    db_names.each do |db_name|
      sh "createdb #{db_name}" do |ok,res|
          #empty block to ignore any failed or success status
      end
    end
  end
end

RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['spec/**/*_spec.rb']
  task.verbose = false
end

task :default => ['specs']
