require "ohm"
require_relative "Unique"

class IType < Ohm::Model

  extend Unique
  index :unique_name
  attribute :unique_name

end
