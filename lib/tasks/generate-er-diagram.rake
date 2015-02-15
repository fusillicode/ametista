desc 'Generate the ER diagram'
task :generate_er_diagram do
  gem_root_dir = File.join Dir.pwd
  require 'global'
  require 'active_record'
  Global.environment = 'development'
  Global.config_directory = File.join(gem_root_dir, 'config')
  ActiveRecord::Base.establish_connection Global.db.to_hash
  require_relative File.join(gem_root_dir, 'lib', 'ametista', 'schema.rb')
  require "rails_erd/diagram/graphviz"
  RailsERD::Diagram::Graphviz.create
end


