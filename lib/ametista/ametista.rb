require "ametista/version"

module Ametista
  class Shine < Thor
    desc "hello NAME", "say hello to NAME"
    options :first_option => :required, :yell => :boolean
    def parse name

    end

    desc "goodbye", "say goodbye to the world"
    def build

    end

    desc "goodbye", "say goodbye to the world"
    def analyze

    end
  end
end
