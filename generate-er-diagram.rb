require 'global'
require 'active_record'
Global.environment = 'development'
Global.config_directory = File.join(Dir.pwd, 'config')
ActiveRecord::Base.establish_connection Global.db.to_hash

require_relative 'lib/ametista/schema.rb'

# Make sure all your models are loaded.
require "rails_erd/diagram/graphviz"

RailsERD::Diagram::Graphviz.create
