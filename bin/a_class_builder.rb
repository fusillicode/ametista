require_relative 'initializer'
require_relative 'model'

class AClassBuilder

  extend Initializer
  initialize_with ({
    ast: nil,
    querier: nil,
  })

end

