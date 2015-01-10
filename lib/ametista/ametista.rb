require "ametista/version"

module Ametista
  class Cli < Thor
    desc "hello NAME", "say hello to NAME"
    options :directory => :required
    def parse
      spawn 'php bin/parse.php'
    end

    desc "goodbye", "say goodbye to the world"
    options :config_files :array
    def build
      require 'global'
      require 'active_record'
      Global.environment = 'development'
      Global.config_directory = File.join(Dir.pwd, 'config')
      ActiveRecord::Base.establish_connection Global.db.to_hash
      # Per pulire il db
      `rake db:reset`
      # `rake db:drop && rake db:create`
      require_relative '../lib/ametista/builders/model_builder'
      model_builder = ModelBuilder.new.build
    end

    desc "goodbye", "say goodbye to the world"
    options :first_option => :required, :yell => :boolean
    def infer
      require 'global'
      require 'active_record'
      Global.environment = 'development'
      Global.config_directory = File.join(Dir.pwd, 'config')
      ActiveRecord::Base.establish_connection Global.db.to_hash
      require_relative '../lib/ametista/rules/inference_engine'
      inference_engine = InferenceEngine.new.infer
    end

    desc "goodbye", "say goodbye to the world"
    options :first_option => :required, :yell => :boolean
    def start
      parse
      build
      infer
    end
  end
end
