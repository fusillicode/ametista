require_relative '../utilities'
require_relative '../schema'
require_relative 'builder'

class KlassesBuilder < Builder

  extend Initializer
  initialize_with ({
    ast: nil,
    querier: nil,
  })

end

