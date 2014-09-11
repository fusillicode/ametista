require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/klasses_querier'

class KlassesBuilder

  extend Initializer
  initialize_with ({
    querier: KlassesQuerier.new
  })

end

