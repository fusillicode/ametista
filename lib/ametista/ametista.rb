require "ametista/version"

module Ametista
  class Shine < Thor
    desc "hello NAME", "say hello to NAME"
    options :directory => :required
    def parse

    end

    desc "goodbye", "say goodbye to the world"
    options :config_files :array
    def build
      # model_builder = ModelBuilder.new.build
    end

    desc "goodbye", "say goodbye to the world"
    options :first_option => :required, :yell => :boolean
    def analyze

    end
  end
end
