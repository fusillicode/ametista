desc 'Generate the ER diagram'
task :generate_er_diagram do
  gem_root_dir = File.join Dir.pwd
  require 'global'
  require 'active_record'
  require "rails_erd/diagram/graphviz"
  require_relative File.join gem_root_dir, 'lib', 'ametista', 'schema.rb'
  Global.environment = 'development'
  Global.config_directory = File.join gem_root_dir, 'config'
  ActiveRecord::Base.establish_connection Global.db.to_hash
  RailsERD::Diagram::Graphviz.create
end


