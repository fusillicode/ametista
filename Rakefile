require 'active_record_migrations'
ActiveRecordMigrations.configure do |c|
  c.yaml_config = 'config/db.yml'
end
ActiveRecordMigrations.load_tasks

Dir['./lib/tasks/*.rake'].sort.each { |task| import task }
