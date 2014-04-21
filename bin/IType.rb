require "ohm"
require_relative "Unique"

class IType < Ohm::Model
  extend Unique
  index :unique_name
  attribute :unique_name

  class << self

    def build_types
      ['bool', 'int', 'double', 'string', 'array', 'null'].each do |type|
        self.create(:unique_name => type)
      end
    end

  end

end
